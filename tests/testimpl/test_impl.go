package testimpl

import (
	"context"
	"errors"
	"fmt"
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/containerregistry/armcontainerregistry"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/privatedns/armprivatedns"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

const (
	DefaultPrivateDNSZoneName = "privatelink.azurecr.io"
)

var (
	RecordTypeA     = armprivatedns.RecordTypeA
	RecordTypeCNAME = armprivatedns.RecordTypeCNAME
	RecordTypeTXT   = armprivatedns.RecordTypeTXT
	backgroundCtx = context.Background()
)

// newAzureConfig creates and returns Azure credentials and DNS client for interacting with Azure services.
// It requires the ARM_SUBSCRIPTION_ID environment variable to be set.
//
// Returns:
//   - *azidentity.DefaultAzureCredential: Azure credential object for authentication
//   - *armprivatedns.RecordSetsClient: Client for managing Azure private DNS record sets
//   - error: Any error encountered during client creation or if ARM_SUBSCRIPTION_ID is not set
//
// The function uses DefaultAzureCredential which attempts authentication through:
//   - Environment variables
//   - Azure CLI credentials
//   - Managed Identity
func newAzureConfig() (*azidentity.DefaultAzureCredential, *armprivatedns.RecordSetsClient, *armcontainerregistry.RegistriesClient, error) {
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		return nil, nil, nil, fmt.Errorf("ARM_SUBSCRIPTION_ID environment variable is not set")
	}
	credential, azErr := azidentity.NewDefaultAzureCredential(nil)

	acrOptions := arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{
			Cloud: cloud.AzurePublic,
		},
	}
	registryClient, acrErr := armcontainerregistry.NewRegistriesClient(
		subscriptionId,
		credential,
		&acrOptions,
	)

	dnsOptions := arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{
			Cloud: cloud.AzurePublic,
		},
	}

	dnsClient, dnsErr := armprivatedns.NewRecordSetsClient(subscriptionId, credential, &dnsOptions)

	return credential, dnsClient, registryClient, errors.Join(azErr, acrErr, dnsErr)
}

// TestComposableComplete verifies the deployment of an Azure Container Registry
// with private endpoints and DNS configuration. It validates:
// - ACR existence
// - Private endpoint DNS record creation
// Parameters:
//   - t: testing context
//   - ctx: terratest context containing terraform configuration
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	_, dnsClient, registryClient, err := newAzureConfig()
	if err != nil {
		t.Fatalf("Unable to get credentials or clients: %e\n", err)
	}

	var (
		acrName                           string
		selfManagedDNSResourceGroupName   string
		externalManagedDNSResourceGroupName string
		dnsResourceGroupName              string
	)

	// Get the ACR and Resource Group names from the Terraform output
	acrName = terraform.Output(t, ctx.TerratestTerraformOptions(), "container_registry_name")
	selfManagedDNSResourceGroupName = terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")

	// Try to get external DNS RG name, use self-managed if not found
	externalManagedDNSResourceGroupName = ""
	if externalDNSRG, err := terraform.OutputE(t, ctx.TerratestTerraformOptions(), "ext_dns_resource_group_name"); err == nil {
		externalManagedDNSResourceGroupName = externalDNSRG
	}

	// Determine which resource group to use for DNS checks
	if externalManagedDNSResourceGroupName != "" && externalManagedDNSResourceGroupName != "null" {
		dnsResourceGroupName = externalManagedDNSResourceGroupName
	} else {
		dnsResourceGroupName = selfManagedDNSResourceGroupName
	}

	t.Run("doesACRExist", func(t *testing.T) {
		// Actually try to get the registry
		registry, err := registryClient.Get(backgroundCtx, selfManagedDNSResourceGroupName, acrName, nil)
		if err != nil {
			t.Fatalf("failed to get ACR %s: %v", acrName, err)
		}

		// Verify the registry exists and is enabled
		assert.NotNil(t, registry.Properties, "ACR properties should not be nil")
		assert.NotNil(t, registry.Properties.LoginServer, "ACR login server should not be nil")
		assert.Equal(t, "Succeeded", string(*registry.Properties.ProvisioningState), "ACR should be successfully provisioned")
	})

	t.Run("doesPrivateEndpointDNSRecordExist", func(t *testing.T) {
		assertDNSRecordExists(t, dnsClient, dnsResourceGroupName, DefaultPrivateDNSZoneName, RecordTypeA, acrName)
	})

	t.Run("doACRTagsExist", func(t *testing.T) {
		registry, err := registryClient.Get(backgroundCtx, selfManagedDNSResourceGroupName, acrName, nil)
		if err != nil {
			t.Fatalf("failed to get ACR %s: %v", acrName, err)
		}
		tags := registry.Tags
		assertTagsContain(t, tags, map[string]string{
			"resource_name": acrName,
		})
	})
}

// assertDNSRecordExists verifies the existence of a specific DNS record in an Azure Private DNS zone.
// It attempts to retrieve the specified DNS record and fails the test if the record cannot be found.
//
// Parameters:
//   - t: Testing object to manage test state and report failures
//   - dnsClient: Azure Private DNS RecordSets client for DNS operations
//   - resourceGroupName: Name of the Azure resource group containing the DNS zone
//   - dnsZoneName: Name of the Private DNS zone
//   - recordType: Type of DNS record (e.g., A, CNAME, etc.)
//   - recordName: Name of the specific DNS record to verify
//
// The function will fail the test if:
//   - The DNS record cannot be retrieved
//   - Any error occurs during the verification process
func assertDNSRecordExists(t *testing.T, dnsClient *armprivatedns.RecordSetsClient, resourceGroupName string, dnsZoneName string, recordType armprivatedns.RecordType, recordName string) {
	stdCtx := context.Background()
	_, err := dnsClient.Get(stdCtx, resourceGroupName, dnsZoneName, recordType, recordName, nil)
	if err != nil {
		t.Fatalf("failed to get DNS record: %v", err)
	}
	assert.Equal(t, nil, err, fmt.Sprintf("%s DNS record should exist in %s zone", recordType, dnsZoneName))
}

// assertTagsContain verifies that a given map of Azure resource tags contains all expected key-value pairs.
// It compares each key-value pair in expectedTags against the actual tags map and fails the test if
// any expected tag is missing or has a different value.
//
// Parameters:
//   - t: Testing object to manage test state and report failures
//   - tags: Map of actual Azure resource tags where key is tag name and value is a pointer to tag value
//   - expectedTags: Map of expected tags where key is tag name and value is the expected tag value
//
// The function will fail the test if:
//   - An expected tag key is not present in the actual tags
//   - The value of an expected tag does not match the actual tag value
func assertTagsContain(t *testing.T, tags map[string]*string, expectedTags map[string]string) {
	for key, value := range expectedTags {
		if val, ok := tags[key]; !ok || *val != value {
			t.Fatalf("expected tag %s to be %s, got %s", key, value, *val)
		}
	}
}
