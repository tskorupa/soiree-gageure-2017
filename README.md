[![CircleCI](https://circleci.com/gh/tskorupa/soiree-gageure-2017/tree/master.svg?style=svg)](https://circleci.com/gh/tskorupa/soiree-gageure-2017/tree/master)

# Contribution guidelines on code architecture

Controllers actions need to be devoid of business logic and devoid of conditional logic. Simple actions are easier to reason about. A controller is responsible for channeling data to the view.

Views must be free of all conditional logic. HTML mixed with ruby is difficult to maintain. Testing a view results in verifying it is rendered for a given action.

The use of serializers is preferred when returning JSON. It allows to isolate the attributes exposed by API from the controller.
