This is a simple chat bot you can use with the www.userlike.com live chat

**Get Started**

1. Create an account at www.userlike.com
2. Create a new operator for you bot
3. Remeber user name and password for this operator

**Install Bot**

1. Install node.js 

   ```brew install node```

2. Install coffeescript

   ```npm install -g coffee-script```


3. Checkout the chat bot repo

   ```git checkout https://github.com/optixx/userlike-chatbot.git```

4. Start bot using your operator credentials

   ```
   cd userlike-chatbot
   coffee bot.coffee   <USERNAME>@userlike.com <PASSWORD>
   ```
   
**How does it work**

The bot opens a xmpp connection to the Userlike system. Each new visitors gets a  session which is State Machine Object.
Every incoming message triggers an event into the State machine, which trigger the message processing and depending on the State Object moves
forwards in the State machine chain.





