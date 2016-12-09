This is a simple chat bot that you can use with the www.userlike.com live chat

**Getting started**

1. Create an account at https://www.userlike.com
2. Add a new operator to you setup https://www.userlike.com/en/dashboard/config/operator/add
3. Remember the username and password of this operator, which we will use later.

**Install the chat bot**

1. Install node.js  (Not using OSX? Take a look here https://nodejs.org/en/download/package-manager/)

   ```brew install node```

2. Install coffeescript

   ```npm install -g coffee-script```


3. Checkout the chat bot repo and install dependencies

   ```
   git checkout https://github.com/optixx/userlike-chatbot.git
   cd userlike-chatbot
   npm install
   ```

4. Start the chat bot using your operator credentials

   ```
   coffee bot.coffee   <USERNAME>@userlike.com <PASSWORD>
   ```

**How does it work**

The bot opens a xmpp connection to the Userlike system. Each new visitors gets a  session which is State Machine Object.
Every incoming message triggers an event into the State machine, which trigger the message processing and depending on the State Object moves
forwards in the State machine chain.


![Step 1](https://raw.githubusercontent.com/optixx/userlike-chatbot/master/assets/step1.png)
![Step 2](https://raw.githubusercontent.com/optixx/userlike-chatbot/master/assets/step2.png)
![Step 3](https://raw.githubusercontent.com/optixx/userlike-chatbot/master/assets/step3.png)
![Step 4](https://raw.githubusercontent.com/optixx/userlike-chatbot/master/assets/step4.png)
