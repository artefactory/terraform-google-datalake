This Terraform module allows you to configure and deploy a data lake with multiples GCS 
buckets, lifecycle rules and other features.

---

[View the module in GitHub](https://github.com/artefactory/terraform-google-datalake)

---

## Pre-requisites

??? success "Install Terraform"

    !!! note
        Tested for Terraform >= v1.4.0

    Use tfswitch to easily install and manage Terraform versions:
    ```console
    $ brew install warrensbox/tap/tfswitch
    
    [...]
    ==> Summary
    🍺  /opt/homebrew/Cellar/tfswitch/0.13.1308: 6 files, 10.1MB, built in 3 seconds
    ==> Running `brew cleanup tfswitch`...
    ```
    ```console
    $ tfswitch
    
    ✔ 1.4.2
    Downloading to: /Users/alexis.vialaret/.terraform.versions
    20588400 bytes downloaded
    Switched terraform to version "1.4.2" 
    ```
  

??? success "Log in to GCP with your default credentials"

    !!! warning 
        Look at the below commands outputs to make sure you're connecting to the right `PROJECT_ID`.
  
    ```console
    gcloud auth login
    
    [...]
    You are now logged in as [alexis.vialaret@artefact.com].
    Your current project is [PROJECT_ID]. You can change this setting by running:
    $ gcloud config set project PROJECT_ID
    ```
    
    ```console
    gcloud auth application-default login

    [...]
    Credentials saved to file: [/Users/alexis.vialaret/.config/gcloud/application_default_credentials.json]
    These credentials will be used by any library that requests Application Default Credentials (ADC).
    Quota project "PROJECT_ID" was added to ADC which can be used by Google client libraries for billing and quota. Note that some services may still bill the project owning the resource.
    ```

---

## Deploy the Data lake module on GCP

⚠️ Experimental status: Some steps will change after putting the module in production (Terraform registry)

=== "One-shot deployment"

    !!! note ""
        This mode of deployment is quicker and easier. It's suitable for projects where the infrastructure is not meant to be managed by Terraform in the long run. Otherwise, prefer the managed deployment workflow.

    Download the directory:

    ```console
    curl -O https://raw.githubusercontent.com/artefactory/terraform-google-datalake/main/
    ```

    ---

    Put yourself into `/examples/standalone` directory and initialize Terraform:
    ```console
    terraform init
    ```

    ??? info "Output"
    ```console
        Initializing modules...
        - datalake in ../..

        Initializing the backend...

        Initializing provider plugins...
        - Finding latest version of hashicorp/random...
        - Finding latest version of hashicorp/google...
        - Installing hashicorp/random v3.5.1...
        - Installed hashicorp/random v3.5.1 (signed by HashiCorp)
        - Installing hashicorp/google v4.62.1...
        - Installed hashicorp/google v4.62.1 (signed by HashiCorp)

        Terraform has created a lock file .terraform.lock.hcl to record the provider
        selections it made above. Include this file in your version control repository
        so that Terraform can guarantee to make the same selections by default when
        you run "terraform init" in the future.

        Terraform has been successfully initialized!

        You may now begin working with Terraform. Try running "terraform plan" to see
        any changes that are required for your infrastructure. All Terraform commands
        should now work.

        If you ever set or change modules or backend configuration for Terraform,
        rerun this command to reinitialize your working directory. If you forget, other
        commands will detect it and remind you to do so if necessary.
    ```

    ---
    Open `main.tf` to modify your GCP project ID and the parameters that you want (buckets,
    lifecycle rules etc.)

    ---
    Apply the infrastructure configuration:
    ```console
    terraform apply
    ```

    ??? info "Output"
    ```console
        [...]

        # module.datalake.google_storage_bucket.buckets["source-b"] will be created
        + resource "google_storage_bucket" "buckets" {
            + force_destroy               = false
            + id                          = (known after apply)
            + location                    = "EUROPE-WEST1"
            + name                        = (known after apply)
            + project                     = "atf-sbx-barthelemy"
            + public_access_prevention    = "enforced"
            + self_link                   = (known after apply)
            + storage_class               = "STANDARD"
            + uniform_bucket_level_access = true
            + url                         = (known after apply)

            + lifecycle_rule {
                + action {
                    + storage_class = "ARCHIVE"
                    + type          = "SetStorageClass"
                    }

                + condition {
                    + age                   = 60
                    + matches_prefix        = []
                    + matches_storage_class = []
                    + matches_suffix        = []
                    + with_state            = (known after apply)
                    }
                }

            + versioning {
                + enabled = (known after apply)
                }

            + website {
                + main_page_suffix = (known after apply)
                + not_found_page   = (known after apply)
                }
            }

        Plan: 3 to add, 0 to change, 0 to destroy.

        Do you want to perform these actions?
        Terraform will perform the actions described above.
        Only 'yes' will be accepted to approve.

        Enter a value: yes

        random_string.prefix: Creating...
        random_string.prefix: Creation complete after 0s [id=hmpq]
        module.datalake.google_storage_bucket.buckets["source-a"]: Creating...
        module.datalake.google_storage_bucket.buckets["source-b"]: Creating...
        module.datalake.google_storage_bucket.buckets["source-b"]: Creation complete after 2s [id=atf-sbx-barthelemy-source-b-hmpq]
        module.datalake.google_storage_bucket.buckets["source-a"]: Creation complete after 2s [id=atf-sbx-barthelemy-source-a-hmpq]
    ```
    
    ---
    Clean up files created by Terraform:
    ```console
    rm -rf .terraform.lock.hcl .terraform terraform.tfstate terraform.tfstate.backup
    ```
