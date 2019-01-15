map_and_rec
=====

An OTP library

Build
-----

    $ rebar3 compile
After cloning the prolect, before compilation ,the user is suposed to go to line 10 of src/map_and_rec.erl and add the path(s) to file(s) where the records are defined either using -include or -include_lib.
And also the user is soposed to replace the code in src/bleashup_and_map.erl starting from line 153 ,replacing with a similar implemetaion of what is there but with his own records.
Then,compilation is going to go successfully.
