Custom Nginx image to run on Fargate 1.4 spot to help capture SIGTERM and transform it to SIGQUIT.

Currently Fargate 1.4 is not supporting sending signal other then SIGTERM as configured in the Dockerfile. 

As a workaround building this custom nginx image with wrapper script to trap the signal SIGTERM and further send SIGQUIT to all nginx processes. 

```
docker build -t mynginx .
docker tag mynginx <repo-uri>/mynginx
docker push <repo-uri>/mynginx
```

Code credits : taylorb-syd@ (https://github.com/taylorb-syd)