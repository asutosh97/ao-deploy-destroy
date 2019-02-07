# ao-deploy-destroy

An automated deploy-destroy architecture for GCP.

## Problem statement

Create an automated  deploy-destroy pipeline for the following sequence of tasks :-

- VM Instance creation by Cloud Function triggering.

- Deployment of a webservice on the instance.

- Testing of the webservice locally.

- Uploading the logs of the webservice to a bucket.

- Destroying the instance if response code is 200.

  

## Step-by-step walkthrough

**NOTE:-**

- I have used Pub/Sub as trigger for Cloud Function since I found it to be more flexible and also I could re-use my code for Pub/Sub triggering [ao-gcp-manage-instances](https://github.com/teraflik/ao-gcp-manage-instance/) which I had previously worked on. But you are free to choose any kind of triggering.
- I am using the [ao-copy-blob](https://github.com/asutosh97/ao-copy-blob) django-webservice which copies a blob from one bucket to another, but again you are free to choose your own.

### 1. Authentication

- Sign-in to [Google Cloud Platform](https://console.cloud.google.com/) with your Google Account having GCP credits and authority to do the following tasks
  - Create and delete instance
  - Create Pub/Sub topics
  - Create Cloud Functions
- Select the relevant project from the drop-down menu.

### 2. Import source code from GitHub to Cloud Source Repositories
*Again, since I am using [ao-copy-blob](https://github.com/asutosh97/ao-copy-blob) for cloud function, I need to import that repo to Cloud Source Repository for it to be used by the cloud function. You are free to use inline editor to code the cloud function. In that case, skip to step 3.*

- Go to the [ao-gcp-manage-instance](https://github.com/teraflik/ao-gcp-manage-instance/) repository.
- Fork that repository.
- Go to [Cloud Source Repositories](https://source.cloud.google.com/).
- Click on **Add Repository** button towards the top right corner.
- Select **Connect external repository** and click **Continue**.
- Select the appropriate **project-id** and in Git Provider,  select **GitHub**.
- Agree the terms and conditions and click **Connect to GitHub**.
- Verify OAuth in GitHub if prompted.
- Select the forked copy of this repository from the list of repositories and click **Connect selected Repository**.
- Once the repository is connected, note down its name, which will somewhat like **github_asutosh97_ao-gcp-manage-instance**

### 3. Create Cloud Function and Pub/Sub Topic

- Go to [Cloud Functions](https://console.cloud.google.com/functions) section and click on **Create Function**.

- Fill in the details as follows :-

- **Name** :- cf-ao-intern-deploy-destroy
- **Memory** :- 512MB
- **Trigger** :- Cloud Pub/Sub
- **Topic** :- Create new topic with **name** :- topic-ao-intern-deploy-destroy
- **Source Code** :- Cloud Source Repository
- **Runtime** :- Python 3.7 (Beta)
- **Repository** :- Name of your repository in Cloud Source Repositories noted down in previous section.
- **Branch** :- master
- **Directory with source code** :- `/`
- **Function to execute** :- cf_manage_instance

Click on More to get more advanced options

- **Region** :- us-central1
- **Timeout** :- 540
- **Service Account** :- Leave this to default service account (which has all the required permissions).

### 4. Modify the bucket-names and file name in Pub/Sub Message and startup-script

Download both the files (pubsub-message.json and startup-script.sh) and do the following modifications.

#### startup-script.sh

- Change the name of buckets, blobs, instance_name and zone accordingly.
- Host this file somewhere in the internet so that it can be accessed via a URL.

#### pubsub-message.json

- Change the configurations as per your requirements. Don't change anything in the **scopes** section as only those scopes relevant for this project are assigned.
- In the `value` of **startup-script-url**, give the URL to access the startup-script.

### 5. Publishing the message in Pub/Sub

- Go to the [Pub/Sub Topics](https://console.cloud.google.com/cloudpubsub)
- Click on your topic-name from the list (mine is `topic-ao-intern-deploy-destroy`)
- Click on **Publish Message**.
- In the message section, paste the contents of the modified **pubsub-message.json** and click **Publish**.

### 6. Monitoring

- You can monitor the triggering of the Cloud Function by going to the `Logs` section of that particular cloud function.
- You can also monitor the creation and deletion of the instance in the Compute Engine section.

### 7. Verifying logfile and copied file in the bucket.

- Check for the copied file in the destination bucket and logfile in the log bucket.

