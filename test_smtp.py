import smtplib

sender = "asamaadmim@gmail.com"
password = "Sa31478."

try:
    print("Connecting to smtp.gmail.com:587...")
    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.starttls()
    print("Logging in...")
    server.login(sender, password)
    print("Login successful!")
    server.quit()
except Exception as e:
    print("Failed!")
    print(e)
