# BNDR ~ An app for planning the ideal night out

# Technologies:  
- The core functionality of BNDR is achieved throught the utilization of the Google Maps and Google Places  APIs, as well as the Flutter framework in tandem with the Firebase real time database
service.

# Main Pages
- Home Page:

- Event Page: The Event Dashboard lets users view all of their upcoming BNDRs, including pending invites and
the events to which they've opted in.

- Planner Pages: The Planner consists of a series of three pages. The first page is where the user
creates the BNDR, names it , and sets a date and time for it to begin. The second page uses the Google Maps
and Places APIs to add locations to the BNDRs itenerary. Some basic information abot each location is
displayed at the bottom of this page, and users may add notes to each individual location as they wish.
Lastly, the third page is where the creator can choose which of their friends to invite to their BNDR, and
send event information to each invitee.

- Friends Page: The Friend page is the hub for connecting to your friends via BNDR. This page displays the 
user's incoming and outgoing friend requests, as well as a list of their current friends.

- Account Info: The Account Info page is where a user can view typical account information like their username and email address

# Backend Services
All data was stored in Google's `Firebase` realtime database. The following features are implemented (Also mention `Google Maps API`)
- Authentication: Firebase authentication ...
- GeoLocation: Google places..
- Friend Request Handling: Firebase...
- Event Request Handling: Firebase...
- Event Creation: Firebase..

    ## Database Schema:
    Insert Schema Here, mention noSQL. 
    - User!
    - Events!
