# Description  
a social media like web app  
## function:  
User can sign up, login, change password, delete his account, show his posts, post articles, delete his posts  
## model: User and Post  
### User  
name:string  
email:string  
password:string  

has_many :posts  
### Post  
date:date  
content:string  
  
belong_to :user  
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
