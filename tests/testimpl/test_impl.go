package testimpl

import (
	"log"
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/containers/azcontainerregistry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {

	// t.Run("TestAlwaysSucceeds", func(t *testing.T) {
	// 	assert.Equal(t, "foo", "foo", "Should always be the same!")
	// 	assert.NotEqual(t, "foo", "bar", "Should never be the same!")
	// })
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Unable to get credentials: %e\n", err)
	}

	options := azcontainerregistry.ClientOptions{
		ClientOptions: azcore.ClientOptions{
			Cloud: cloud.AzurePublic,
		},
	}

	acrName := terraform.Output(t, ctx.TerratestTerraformOptions(), "container_registry_name")


	t.Run("doesACRExist", func(t *testing.T) {
		_, err := azcontainerregistry.NewClient(acrName + ".azurecr.io", credential, &options)
		if err != nil {
			log.Fatalf("failed to create client: %v", err)
		}

		assert.Equal(t, nil, err, "ACR should exist")
	})

}
