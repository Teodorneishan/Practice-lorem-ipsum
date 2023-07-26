# Practice-lorem-ipsum
static website , hosted in s3 , with cloudfront configured for scalability and automated with Terraform


I have created :
- s3 bucket in amazon 
- uploaded lorem.html file which consist of text and image as requested
- created static web site , hosted in s3 to serve that content
- added cloudfront for improving performance and distribution of the website
    - content distribution
    - caching
    - ssl/tls termination
    - custom domain and ssl
- have tried to automate this as much as possible with terraform , with minimal
- after deploy , i make little touches like
    - edit policy of bucket (enable Block all public access), to be accessible only from cloud front ( since there is nothing dynamic at our page , we can use static cached content only)
    https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipalReadOnly",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::<S3 bucket name>/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::<AWS account ID>:distribution/<CloudFront distribution ID>"
                }
            }
        },
        {
            "Sid": "AllowLegacyOAIReadOnly",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity <origin access identity ID>"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::<S3 bucket name>/*"
        }
    ]
    }


    Access page : https://d26dmj7dsow997.cloudfront.net/
    


Amazon CloudFront is a content delivery network (CDN) service provided by Amazon Web Services (AWS). When using a static S3 (Simple Storage Service) webpage, CloudFront can significantly improve the performance and distribution of your website's static content worldwide. Here's the idea behind using CloudFront with a static S3 webpage
- Content Distribution - When you host your static website on an S3 bucket, it's stored in a specific AWS region. Users located far away from that region may experience slower loading times due to increased latency.CloudFront helps distribute your website's static content to multiple edge locations (data centers) around the world, which are geographically closer to your users. This reduces the physical distance data needs to travel, resulting in faster loading times.

- Caching - CloudFront caches your static content at the edge locations. When a user requests a particular file from your S3 bucket, CloudFront first checks if it has a cached copy in the nearest edge location.

- SSL/TLS Termination - CloudFront can handle SSL/TLS (Secure Sockets Layer/Transport Layer Security) termination, which means it can handle HTTPS requests directly

- Custom Domain and SSL - CloudFront allows you to use a custom domain name (e.g., www.example.com) for your static website instead of the default S3 bucket URL
- Reduced Costs
- Security and Access Control