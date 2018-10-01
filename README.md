# Model:  
## User  
name:string  
email:string  
password:string  

has_many :posts  
## Post  
date:date  
content:string  

belong_to :user
# Function:
## User
sign up
login
change password
show posts
post
