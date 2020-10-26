# CaCertUrlSessionError
Demo playground for error with a private certificate authority and URLSession.

I'm having trouble using URLSession to retrieve data from a server with an SSL
cert signed by a private Certificate Authority.  I can embed the CA certificate
in the app and I think I've added it properly as an anchor certificate, but 
when I try to load data, the evaluation fails with:

Certificate 0 “52.72.125.50” has errors: Extended key usage does not match certificate usage; 

Using curl from the command line, I can run this command successfully:

```
curl --cacert callisto_staging_ca.pem https://52.72.125.50/hello
```

And receive the reply

```
{"message":"Hello World"}
```

The PEM file used by curl was converted to DER format for URLSession with the
 following command:

```
openssl x509 -in callisto_staging_ca.pem -outform der -out callisto_staging_ca.der
```
