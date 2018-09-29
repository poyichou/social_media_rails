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
delete account  
show posts  
post articles  
delete post  
# Before using  
```bash
bundle install
bin/rails db:migrate
```  
# To run  
```bash
bin/rails s
# open your browser and connect to localhost:3000
```
