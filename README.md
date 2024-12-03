# BNDR ~ An app for planning the ideal night out

# Technologies:  
- The core functionality of BNDR is achieved throught the utilization of the Google Maps and Google Places  APIs, as well as the Flutter framework in tandem with the Firebase real time database
service.

# Installation Guide
- Install the most up-to-date version of the Flutter SDK for your specific system. This is a lengthy and confusing process so be sure to follow instructions carefully and completely.
  - Here is the URL to install the latest version of the Flutter SDK: https://docs.flutter.dev/get-started/install
- We recommend using Microsoft's Visual Studio Code and an Apple machine as Apple allows you to open an IPhone Simulator with Xcode. You can also use Andriod Studio on Windows but our testing is extremely limited with that and normally use Chrome as our testing vessle on Windows.
- Once Flutter is installed and you have ran the `flutter doctor` command with no errors, you are set to go.
- NOTE: every machine is different and has different software preinstalled before Flutter so your installation process can be different from ours or your friends'.

# Main Pages
- Home Page: The Home Page is simply a starting place to browse nearby locations.

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
