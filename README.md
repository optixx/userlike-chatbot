This is a simple chat bot that you can use with the www.userlike.com live chat

# HTTP integration

## Getting started

1. Create an account at https://www.userlike.com
2. Add a new operator bot https://www.userlike.com/en/dashboard/config/operator/bot/add

## Run sample

1. Install python pip by following this instructions https://pip.pypa.io/en/stable/installing/

2. Checkout the chat bot repo and install dependencies

   ```
   git checkout https://github.com/optixx/userlike-chatbot.git
   cd http-chatbot-integration
   pip install -r requirements.txt
   ```

3. Start the chat bot

   ```
   export FLASK_APP=app.py
   flask run
   ```

### How does it work

First we give you an overview on request/response values for your three HTTP endpoints. Further below we describe the JSON exchange format in more detail and explain how your chatbot (framework) must use it for maintaining state for each chat with your Webvisitors.

With one exception, all requests to and responses from your chatbot (framework) must use the HTTP POST method - only the first request to the "chat start endpoint" will be made using the HTTP GET method, (without parameters). It is possible that in the future we'll use the POST method for the first request as well, so best make your endpoint accept both methods.

https://wwww.userlike.com/en/public/tutorial/chat_bots


# XMPP integration

## Getting started

1. Create an account at https://www.userlike.com
2. Add a new operator to you setup https://www.userlike.com/en/dashboard/config/operator/add
3. Remember the username and password of this operator, which we will use later.

## Run sample

1. Install node.js  (Not using OSX? Take a look here https://nodejs.org/en/download/package-manager/)

   ```brew install node```

2. Install coffeescript

   ```npm install -g coffee-script```


3. Checkout the chat bot repo and install dependencies

   ```
   git checkout https://github.com/optixx/userlike-chatbot.git
   cd xmpp-chatbot-integration
   npm install
   ```

4. Start the chat bot using your operator credentials

   ```
   coffee bot.coffee   <USERNAME>@userlike.com <PASSWORD>
   ```

### How does it work

The bot opens a xmpp connection to the Userlike system. Each new visitors gets a  session which is State Machine Object.
Every incoming message triggers an event into the State machine, which trigger the message processing and depending on the State Object moves
forwards in the State machine chain.

https://staging.userlike.com/en/public/tutorial/chat_bots_xmpp


![Step 1](https://raw.githubusercontent.com/optixx/userlike-chatbot/master/assets/step1.png)
![Step 2](https://raw.githubusercontent.com/optixx/userlike-chatbot/master/assets/step2.png)
![Step 3](https://raw.githubusercontent.com/optixx/userlike-chatbot/master/assets/step3.png)
![Step 4](https://raw.githubusercontent.com/optixx/userlike-chatbot/master/assets/step4.png)
