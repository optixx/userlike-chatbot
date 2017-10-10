# -*- coding: UTF-8 -*-
import re
from flask import Flask, jsonify, request
from email_validator import validate_email, EmailNotValidError
app = Flask(__name__)


@app.route("/hello", methods=['GET', 'POST'])
def hello():
    app.logger.info('Starting Chat')
    state = get_state()
    return state.answer()


@app.route("/message", methods=['GET', 'POST'])
def message():
    app.logger.info('Chatting')
    state = get_state()
    return state.answer()


@app.route("/bye", methods=['GET', 'POST'])
def bye():
    app.logger.info('Ending Chat')
    return jsonify({"answers": "Good bye!"})


def get_state():
    try:
        state = request.get_json().get("context").get("state")
        klass = globals().get("State%s" % state.capitalize())
        return klass(request.get_json().get("input"))
    except:
        return StateStart()


class State(object):
    next_state = ""

    def __init__(self, input=None):
        self.input = input
        app.logger.info('Entering state=%s with input=%s', self.__class__.__name__, self.input)

    def _make_answer(self, answers, context={}):
        _context = {"state": self.next_state}
        _context.update(context)
        return jsonify({
            "answers": answers,
            "context": _context
        })


class StateStart(State):
    next_state = "setname"

    def answer(self):
        if self.input:
            return self._make_answer(self.input)
        return self._make_answer(["Before we proceed, could you please tell me your name?"])


class StateSetname(State):
    next_state = "setemail"

    def answer(self):
        if len(self.input) < 3:
            self.next_state = "setname"
            return self._make_answer("Sorry, could you provide your name again?")
        return self._make_answer(["$name %s" % self.input, "Hello %s, please provide your email, too." % self.input])


class StateSetemail(State):
    next_state = "setphone"

    def answer(self):
        try:
            res = validate_email(self.input)
            email = res["email"]
        except EmailNotValidError as e:
            # email is not valid, exception message is human-readable
            self.next_state = "setemail"
            return self._make_answer([str(e), "Sorry, a valid email is required. Please try again..."])
        return self._make_answer(["$email %s" % email, "Thank you. May I also ask your phone number?"])


class StateSetphone(State):
    next_state = "askforward"

    def answer(self):
        phone_regex = re.compile(r"\+?[0-9+-/]{8,25}")
        phone_match = re.search(phone_regex, self.input)
        if self.input.lower() in NEGATION:
            return self._make_answer("No problem.")
        if not phone_match:
            self.next_state = "setphone"
            return self._make_answer(["I did not recognize the number you provided: '%s'" % self.input, "Could you try again?"])
        return self._make_answer(["$additional01 %s" % phone_match, "Thank you."])


class StateAskforward(State):
    next_state = "forward"

    def answer(self):
        return self._make_answer(["That is all I can do for you for now. Should I forward you to my human colleagues now (yes/no)?", "Otherwise I'll create a ticket for you..."])


class StateForward(State):
    next_state = "end"

    def answer(self):
        if self.input.lower() in AFFIRMATIVE:
            return self._make_answer(["Forwarding you to the next free human Operator...", "$any"])
        else:
            return self._make_answer(["Creating a ticket. Thanks for your visit, goodbye!", "$emailticket"])


class StateEnd(State):
    next_state = "end"

    def answer(self):
        return self._make_answer("Thanks for your visit, goodbye!")


AFFIRMATIVE = ("y", "yes", "yeah", "ok")
NEGATION = ("n", "no", "nope", "no way")
