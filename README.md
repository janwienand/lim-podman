# License Infrastructure Manager
## ❓ Description

This repo contains the files required for a Podman Fortify License Infrastructure Manager (LIM) deployment.

## 🎉 Deployment

### 🐳 Offline image retrieval

If you plan to deploy this component on an offline environment, below are the commands to save the Docker image for loading in the destination environment:

1. First login to Docker Hub using your Docker Hub credentials:
   ```sh
   podman login -u <Docker hub username>
   ```

2. Then save the image locally:
   ```sh
   podman save fortifydocker/lim:<tag> -o lim.tar
   ```

3. Get this tar file in the destination environment, and load it:
   ```sh
   podman load -i lim.tar
   ```

**_NOTE:_** This step is not required if you have a direct connection to Docker Hub.

### 🐳 Deployment

1. Create a `data` and `secrets` folder
2. Create Server Certificate:
   ```sh
   LIM_SERVER_CERT_PWD="$(openssl rand -base64 32)"

   openssl req \
    -newkey rsa:2048 \
    -new -nodes -x509 -days 3650 \
    -keyout secrets/lim-server-key.pem \
    -out secrets/lim-server-cert.pem \
    -subj "/C=CA/ST=Ontario/L=Waterloo/O=OpenText/OU=IT"

   openssl pkcs12 -export \
    -out secrets/lim-server-cert.pfx \
    -inkey secrets/lim-server-key.pem \
    -in secrets/lim-server-cert.pem \
    -passout "pass:${LIM_SERVER_CERT_PWD}"

   echo "Paste the following value in .env > ASPNETCORE_Kestrel__Certificates__Default__Password : $LIM_SERVER_CERT_PWD"
   ```

3. Create Signing Certificate:
   ```sh
   LIM_SIGNING_CERT_PWD="$(openssl rand -base64 32)"

   openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 \
    -keyout secrets/lim-signing-key.pem \
    -out secrets/lim-signing-cert.pem \
    -subj "/C=CA/ST=Ontario/L=Waterloo/O=OpenText/OU=IT"

   openssl pkcs12 -export \
    -out secrets/lim-signing-cert.pfx \
    -inkey secrets/lim-signing-key.pem \
    -in secrets/lim-signing-cert.pem \
    -passout "pass:${LIM_SIGNING_CERT_PWD}"

   echo "Paste the following value in .env > Signing__CertificatePassword : $LIM_SIGNING_CERT_PWD"
   ```

4. Copy or rename `.env.template` to `.env`. Review and edit the `.env` file:
   
   1. Generate JWT Security Key:
      ```sh
      openssl rand -base64 32 | tr -d '[:punct:]'
      ```
      Set this value in .env > `JWT__SecurityKey`.
   2. Change any value set to `changeme`.

5. Review and edit the `docker-compose.yml` file if needed.
6. Set write permissions to your container:
   ```sh
   sudo chmod -R 777 data secrets
   ```
   
   Or run:
   ```sh
   sudo ./check-volumes-permissions.sh
   ```

7. Run the following command:
   ```sh
   podman compose up -d
   ```
   
   You can tail the logs using the following command:
   ```sh
   podman compose logs -f
   ```
