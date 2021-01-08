*** Settings ***
Documentation     Resource consisting purely of variable definitions useful for multiple project suites.
...
...
...
...               These variables are considered global and immutable, so their names are in ALL_CAPS.
...
...               If a variable is only specific to few projects, define it in csit/variables/{project}/Variables.robot file instead.
...               If a variable only affects few Resources, define it in csit/libraries/{resource}.robot file instead.
...
...               Please include a short comment on why the variable is useful and why particular value was chosen.
...               Also a well-known variables provided by releng/builder script should be listed here,
...               the value should be a reasonable default.
...

*** Variables ***
# Keep this list sorted alphabetically.