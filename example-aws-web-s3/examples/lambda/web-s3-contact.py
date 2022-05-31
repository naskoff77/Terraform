import os
import json
import boto3
from botocore.exceptions import ClientError


def contact_handler(event, context):
    # Get run env
    ENV = os.getenv('env')
    if ENV == 'dev':
        SENDER = "customercontact.dev@exampledomain.com"
    else:
        SENDER = "customercontact.www@exampledomain.com"

    # If your account is still in the sandbox, this address must be verified.
    RECIPIENT = "contact@exampledomain.com"

    # The subject line for the email.
    SUBJECT = "{SENDER} has contacted you from exampledomain.com's contact form!"

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = ("{SENDER} has contacted you from exampledomain.com's contact form!\r\nName: {customer_name}\r\nE-mail: {customer_email}\r\nPhone: {customer_phone}\r\nMessage:\r\n")

    # The HTML body of the email.
    BODY_HTML = """<html>
    <head></head>
    <body>
      <h1>{SENDER} has contacted you from exampledomain.com's contact form!</h1>
      <p>
      Name: {customer_name}
      E-mail: {customer_email}
      Phone: {customer_phone}
      Message: {customer_message}
      </p>
    </body>
    </html>
                """

    # The character encoding for the email.
    CHARSET = "UTF-8"
    # Create SES client (edited)
    ses = boto3.client('ses')
    try:
        # Provide the contents of the email.
        response = ses.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER
        )
    # Display an error if something goes wrong.
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Your message has been sent. We will be in touch soon!"),

    return {
        'statusCode': 200,
    }
