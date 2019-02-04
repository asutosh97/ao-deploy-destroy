# Defining Variables
source_bucket_name="b-ao-intern-test1"
source_blob_name="kitten.png"
destination_bucket_name="b-ao-intern-test2"
destination_blob_name="kitten.png"
log_bucket="b-ao-intern-test2"
instance_name="i-ao-intern-deploy-destroy"
zone="us-central1-c"

# Update the library info
sudo apt update
# Cloning the Django Project Repo
git clone https://github.com/asutosh97/ao-copy-blob.git
# moving into the repo
cd ao-copy-blob/
# Installing pip
sudo apt install python-pip -y
# Installing python3
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.6 -y
# installing virtualenv
sudo pip install virtualenv
# creating a virtualenv
virtualenv -p python3 env
# activating the virtual env
source env/bin/activate
# installing dependencies
pip install -r requirements.txt
# running the server as a background process and saving the logs
python django_webservice/manage.py runserver 0.0.0.0:8000 &> logs.txt &
# wait for the server to run properly
sleep 5
# test the endpoint
response_code=$(curl --header "Content-Type: application/json" --request POST --data "{\"source_bucket_name\": \"${source_bucket_name}\", \"source_blob_name\": \"${source_blob_name}\", \"destination_bucket_name\": \"${destination_bucket_name}\", \"destination_blob_name\": \"${destination_blob_name}\"}" -s -o /dev/null -w "%{http_code}" http://0.0.0.0:8000/copy_blob/)
# concatenate contents of old_logfile if it exists and then upload to bucket.
touch old_logfile.txt
gsutil cp gs://${log_bucket}/logfile.txt ./old_logfile.txt
cat old_logfile.txt > logfile.txt
echo >> logfile.txt
cat logs.txt >> logfile.txt
gsutil cp ./logfile.txt gs://${log_bucket}/logfile.txt
# if success then publish delete_instance message to pubsub
if [ $response_code -eq 200 ]; then
	gcloud compute instances delete ${instance_name} --zone=${zone} -q
fi
