import gspread
#import oauth2client

# Create a Google OAuth2 client
gc = gspread.service_account(filename='cred.json')

# Open your Google Sheet
sh = gc.open('practice')

# Get the worksheet
worksheet = sh.worksheet('Sheet1')

# Get the id
id = 23

# Get the name by id
name = worksheet.cell(f'B{id}').value

# Print the name
print(name)
