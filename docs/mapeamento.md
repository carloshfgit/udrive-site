You can set up a custom domain rather than the default address that
Cloud Run provides for a deployed service.

There are a few ways to set up a custom domain for a Cloud Run
service:

- Use a [global external Application Load Balancer](https://docs.cloud.google.com/run/docs/mapping-custom-domains#https-load-balancer) (Recommended)
- Use [Cloud Run domain mapping (Limited availability and Preview)](https://docs.cloud.google.com/run/docs/mapping-custom-domains#run)
- Use [Firebase Hosting](https://docs.cloud.google.com/run/docs/mapping-custom-domains#firebase)

You can map multiple custom domains to the same Cloud Run service.

## Before you begin

Purchase a new domain, unless you already have one that you want to use. You
can use any domain name registrar.

## Map a custom domain using a global external Application Load Balancer

With this option, you add a [global external Application Load Balancer](https://docs.cloud.google.com/load-balancing/docs/https)
in front of your Cloud Run service and configure a custom domain at
the load balancer level.

One advantage of using a global external Application Load Balancer is that it gives you a lot of
control around your custom domain setup.
For example, it lets you use your own TLS certificate or route
specific URL paths to the Cloud Run service.
It also lets you configure [Cloud CDN](https://docs.cloud.google.com/cdn) for caching and [Google Cloud Armor](https://docs.cloud.google.com/armor)
for additional security.

You can also map multiple services to a dynamic hostname or
path in your custom domain URL pattern for a single load balancer, for example, `<service>.example.com`,
using [URL masks](https://docs.cloud.google.com/load-balancing/docs/https/setup-global-ext-https-serverless#using-url-mask).

Refer to the documentation on [setting up a global external Application Load Balancer with Cloud Run](https://docs.cloud.google.com/load-balancing/docs/https/setup-global-ext-https-serverless).

## Map a custom domain using Cloud Run domain mapping (Limited availability and Preview)

> [!WARNING]
>
> **Preview
> --- Cloud Run domain mappings**
>
>
> This feature is
>
> subject to the "Pre-GA Offerings Terms" in the General Service Terms section of the
> [Service Specific
> Terms](https://docs.cloud.google.com/terms/service-terms#1).
>
> Pre-GA features are available "as is" and might have limited support.
>
> For more information, see the
> [launch stage descriptions](https://cloud.google.com/products/#product-launch-stages).

### Cloud Run domain mapping limitations

The following considerations apply to Cloud Run domain mappings:

- Cloud Run domain mappings are in the [preview launch stage](https://cloud.google.com/products#product-launch-stages). Due to [latency issues](https://docs.cloud.google.com/run/docs/issues#latency-domains), they are not production-ready and are not supported at General Availability. At the moment, this option is not recommended for production services.
- A Google-managed certificate for HTTPS connections is automatically issued and renewed when you map a service to a custom domain.
- Provisioning the SSL certificate usually takes about 15 minutes but can take up to 24 hours.
- You cannot disable TLS 1.0 and 1.1. If this is an issue, you can use Firebase Hosting or Cloud Load Balancing to enable TLS 1.2-only traffic.
- You cannot upload and use your own (self-managed) certificates.
- Cloud Run domain mappings are limited to 64 characters.
- Domain mapping is available in the following regions:
  - `asia-east1`
  - `asia-northeast1`
  - `asia-southeast1`
  - `europe-north1`
  - `europe-west1`
  - `europe-west4`
  - `us-central1`
  - `us-east1`
  - `us-east4`
  - `us-west1`
- To map custom domains in other regions, you must use one of the other mapping options.
- When you use Cloud Run domain mappings, you map a custom domain to your service, then update your DNS records.
- You can map a domain, such as `example.com` or a subdomain, such as `subdomain.example.com`.
- You can only map a domain to `/`, not to a specific URL path like `/users`.
- You cannot use wildcard certificates with this feature.

### Map a custom domain to a service

You can use the Google Cloud console, gcloud CLI, or Terraform to map a
custom domain to a service.

> [!NOTE]
> **Note:** If you have already configured domain forwarding on a third-party load balancer, you don't need to use Cloud Run domain mapping. Ensure that the forwarding settings on the third-party load balancer are set correctly.

### Console

1. Open the domain mappings page in the Google Cloud console:  

   [Domain mappings page](https://console.cloud.google.com/run/domains)

2. Click **Add Mapping**.

   If your display window is too small, the **Add Mapping** button isn't
   displayed and you must click the three-dot vertical ellipse icon in the
   corner of the page.
3. From the drop-down list, select the service you are mapping the custom
   domain to.

4. Select **Cloud Run Domain Mappings**.

5. In the **Add mapping** form, select **Verify a new domain**.

6. In the **Base domain to verify** field, you must verify the ownership of
   a domain before you can use it, unless you purchased your domain
   from Google.

   If you want to map `subdomain.example.com` or
   `subdomain1.subdomain2.example.com`, you must verify ownership
   of `example.com`.
   For more information on verifying domain ownership, refer to
   [Search Console help](https://support.google.com/webmasters/answer/9008080).
7. Click **Continue**.

8. After domain verification is finished, click **Continue verification and close**.

9. [Update your DNS records](https://docs.cloud.google.com/run/docs/mapping-custom-domains#dns_update) at your domain registrar
   website using the DNS records displayed in the last step.
   You can display the records at any time by clicking **DNS Records** in
   the "..." action menu for a domain mapping.

10. Click **Done**.

### gcloud

1. You must verify domain ownership the first
   time you use that domain in the Google Cloud project, unless you purchased your
   custom domain from Google.
   You can determine whether the custom domain you want to use has been
   verified by running the following command:

   <br />

   ```bash
   gcloud domains list-user-verified
   ```

   <br />

   If your ownership of the domain needs to be
   verified, open the Search Console verification page:

   ```bash
   gcloud domains verify BASE-DOMAIN
   ```

   where `BASE-DOMAIN` is the base domain you want
   to verify. For example, if you want to map `subdomain.example.com`, you
   must verify the ownership of `example.com`.

   In *Search Console* , complete domain ownership verification. For
   more information, refer to
   [Search Console help](https://support.google.com/webmasters/answer/9008080?hl=en).
2. Map your service to the custom domain:

   ```bash
   gcloud beta run domain-mappings create --service SERVICE --domain DOMAIN
   ```
   - Replace `SERVICE` with your service name.
   - Replace `DOMAIN` with your custom domain, for example, `example.com` or `subdomain.example.com`

> [!NOTE]
> **Note:** If you are using a domain that is already mapped to another service, use the [`--force-override` flag](https://docs.cloud.google.com/sdk/gcloud/reference/run/domain-mappings/create#--force-override) when you create the domain mapping. That domain will be removed from the other service to point to this one.

### Terraform


To learn how to apply or remove a Terraform configuration, see
[Basic Terraform commands](https://docs.cloud.google.com/docs/terraform/basic-commands).

<br />

To create a Cloud Run service, add the following to your existing `main.tf` file:

    resource "google_cloud_run_v2_service" "default" {
      name     = "custom-domain" # Replace with your service name
      location = "us-central1"

      deletion_protection = false # set to true to prevent destruction of the resource

      template {
        containers {
          image = "us-docker.pkg.dev/cloudrun/container/hello" # Replace with your container image
        }
      }
    }

Replace:

- `custom-domain` with your Cloud Run service name.
- `us-docker.pkg.dev/cloudrun/container/hello` with a reference to your container image. If you use Artifact Registry, the [repository](https://docs.cloud.google.com/artifact-registry/docs/repositories/create-repos#docker) <var translate="no">REPO_NAME</var> must already be created. The URL has the shape `LOCATION-docker.pkg.dev/PROJECT_ID/REPO_NAME/PATH:TAG`.

Map your Cloud Run service to the custom domain:

    data "google_project" "project" {}

    resource "google_cloud_run_domain_mapping" "default" {
      name     = "verified-domain.com"
      location = google_cloud_run_v2_service.default.location
      metadata {
        namespace = data.google_project.project.project_id
      }
      spec {
        route_name = google_cloud_run_v2_service.default.name
      }
    }

Replace `verified-domain.com` with your custom verified domain, for example, `example.com` or `subdomain.example.com`.

### Add your DNS records at your domain registrar

After you've mapped your service to a custom domain in Cloud Run,
you must update your DNS records at your domain registrar. As a convenience,
Cloud Run generates and displays the DNS records you must enter. You
must add these records that point to the Cloud Run service at your
domain registrar for the mapping to go into effect.

If you're using Cloud DNS as your DNS provider, see [Adding a
record](https://docs.cloud.google.com/dns/docs/records#adding_a_record).

> [!NOTE]
> **Note:** Some third-party CDN providers might inadvertently intercept validation requests, preventing them from reaching the Cloud Run service and causing the domain mapping to fail or its certificate to fail to renew. For example, if you are using Cloudflare CDN, you must turn off the "*Always use https* " option in the "*Edge Certificates* " tab of the *SSL/TLS* tab.

1. Retrieve the DNS record information for your domain mappings using the following:

   ### Console

   1. Go to the Cloud Run domain mappings page:  

      [Domain mappings page](https://console.cloud.google.com/run/domains)

   2. Click the three-dot vertical ellipse icon to the right of your service,
      then click **DNS RECORDS** to display all the DNS records:

   ![select DNS records](https://docs.cloud.google.com/static/run/docs/images/select-dns.png)

   ### gcloud

   ```bash
   gcloud beta run domain-mappings describe --domain [DOMAIN]
   ```

   Replace `[DOMAIN]` with your custom domain, for example, `example.com` or
   `subdomain.example.com`.

   You need all of the records returned under the heading `resourceRecords`.
2. Sign in to your account at your domain registrar and then open the DNS
   configuration page.

3. Locate the host records section of your domain's configuration page and
   then add each of the resource records that you received when you mapped
   your domain to your Cloud Run service.

4. When you add each of the previous DNS records to the account at the DNS provider:

   - Select the type returned in the DNS record in the previous step: `A`, or `AAAA`, or `CNAME`.
   - Use the name `www` to map to `www.example.com`.
   - Use the name `@` to map `example.com`.
5. Save your changes in the DNS configuration page of your domain's account.
   In most cases, it takes only a few minutes for these changes to take effect, but
   in some cases it can take up to several hours, depending on the registrar and
   the [Time-To-Live (TTL)](https://support.google.com/a/answer/48090?hl=en) of any
   previous DNS records for your domain. You can use a
   [`dig`](https://en.wikipedia.org/wiki/Dig_(command)) tool, such as
   the [online `dig` version](https://toolbox.googleapps.com/apps/dig/#A/),
   to confirm the DNS records have been successfully updated.

6. Test for success by browsing to your service at its new URL, for
   example, `https://www.example.com`. It can take several minutes for
   the managed SSL certificate to be issued.

### Add verified domain owners to other users or service accounts

When a user verifies a domain, that domain is only verified
to that user's account. This means that only that user can add more domain
mappings that use that domain. So, to enable other users to add mappings that
use that domain, you must add them as verified owners.

> [!NOTE]
> **Note:** A verified domain owner can override existing domain mappings from other projects after confirmation.

If you need to add verified owners of your domain to other users or
service accounts, you can add permission through the *Search Console* page:

1. Navigate to the following address in your web browser:

   [`https://search.google.com/search-console/welcome`](https://search.google.com/search-console/welcome)
2. Under **Properties**, click the domain that you want to add a user or service
   account to.

3. Go to the **Verified owners** list, click **Add an owner**, and
   then enter a Google Account email address or service account ID.

   To view a list of your service accounts, open the Service Accounts
   page in the Google Cloud console:

   [Go to Service Accounts page](https://console.cloud.google.com/iam-admin/serviceaccounts)

### Delete a Cloud Run domain mapping

You can use the Google Cloud console or the gcloud CLI to delete
a domain mapping.

### Console

1. Open the Domain mappings page in the Google Cloud console:  

   [Domain mappings page](https://console.cloud.google.com/run/domains)

2. In the **Domain mappings** page, select the domain mapping that you want
   to delete and click **Delete**.

### gcloud

1. Delete the domain mapping:

   ```bash
   gcloud beta run domain-mappings delete --domain DOMAIN
   ```
   - Replace `DOMAIN` with your custom domain, for example, `example.com` or `subdomain.example.com`.

## Map a custom domain using Firebase Hosting

> [!NOTE]
> **Note:** Firebase Hosting is not covered by [Google Cloud Terms of Service](https://cloud.google.com/terms). See [Terms of Service for Firebase Services](https://firebase.google.com/terms).

With this option, you configure [Firebase Hosting](https://firebase.google.com/docs/hosting)
in front of your Cloud Run service and connect a domain to Firebase
Hosting.

Using Firebase Hosting has a low price and optionally lets you host and
serve static content alongside the dynamic content served by your
Cloud Run service.

To map a custom domain using Firebase Hosting:

1. [Add Firebase to your Google Cloud project](https://firebase.google.com/docs/web/setup).
2. [Install the Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli).
3. In a folder different from the source code of your service, create a
   `firebase.json` file with the following content:

         {
           "hosting": {
             "rewrites": [{
               "source": "**",
               "run": {
                 "serviceId": "SERVICE_NAME",
                 "region": "REGION"
               }
             }]
           }
         }

   Replace <var translate="no">SERVICE_NAME</var> and <var translate="no">REGION</var> with the name and
   region of your Cloud Run service.
4. Deploy the Firebase Hosting configuration:

   ```bash
   firebase deploy --only hosting --project PROJECT_ID
   ```
5. [Connect a custom domain to Firebase Hosting](https://firebase.google.com/docs/hosting/custom-domain).

Read more about [Firebase Hosting and Cloud Run](https://firebase.google.com/docs/hosting/cloud-run#direct_requests_to_container).

## Using custom domains with authenticated services

Authenticated services are [protected by IAM](https://docs.cloud.google.com/run/docs/securing/managing-access).
Such Cloud Run services require client authentication that
declares the intended recipient of a request at credential-generation time (the
*audience*).

Audience is usually the full URL of the target service, which by default for
Cloud Run services is a generated URL ending in
`run.app`.

If you use a custom domain, however, you can [configure a custom audience](https://docs.cloud.google.com/run/docs/configuring/custom-audiences)
so that your service accepts your custom domain as a valid audience.

## What's next

- Learn how to [secure your Cloud Run services](https://docs.cloud.google.com/run/docs/tutorials/secure-services).
- To set up a custom domain for Cloud Run by using a global external Application Load Balancer, see [Set up a global external Application Load Balancer with Cloud Run](https://docs.cloud.google.com/load-balancing/docs/https/setup-global-ext-https-serverless).