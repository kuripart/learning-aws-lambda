FROM public.ecr.aws/lambda/python:3.8

COPY test.py ${LAMBDA_TASK_ROOT}

# Command can be overwritten by providing a different command in the template directly.
CMD ["test.lambda_handler"]

# https://stackoverflow.com/questions/17325293/invoke-webrequest-post-with-parameters
# https://stackoverflow.com/questions/70153449/errormessage-unable-to-unmarshal-input-expecting-value-line-1-column-1-c

# PS C:\Users\Parth\Documents\PC - Part 4\Programming\aws-lambda-works> Invoke-WebRequest "http://localhost:9000/2015-03-31/functions/function/invocations" -Method POST -Body "{}"


# StatusCode        : 200
# StatusDescription : OK
# Content           : {"statusCode": 200, "body": "{\"message\": \"Hello World\"}"}
# RawContent        : HTTP/1.1 200 OK
#                     Content-Length: 61
#                     Content-Type: text/plain; charset=utf-8
#                     Date: Sun, 27 Feb 2022 08:33:13 GMT

#                     {"statusCode": 200, "body": "{\"message\": \"Hello World\"}"}
# Forms             : {}
# Headers           : {[Content-Length, 61], [Content-Type, text/plain; charset=utf-8], [Date, Sun, 27 Feb 2022 08:33:13 GMT]}
# Images            : {}
# InputFields       : {}
# Links             : {}
# ParsedHtml        : System.__ComObject
# RawContentLength  : 61
