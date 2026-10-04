# Untested changes (2026-10-04)

NumLock default by hardware (task a113): `q4hw-info --numpad` guesses whether the keyboard has a numeric keypad (non-laptop chassis, or a laptop with an internal panel at least 34 cm wide); `first_boot.sh` sets the login screen (tdm, sddm) and `populate_homedir.sh` the Trinity and Plasma `kcminputrc` of each new user. Installed systems and existing users are not touched.

Written here uncommitted and without a build of this tree. The three scripts are byte-identical to the copies tested in a113 (Q4OS 6.9 Trinity and Plasma guests, report in `a_tasks_workdir/a113_numlock_default/REPORT.md`). Still untested: a real first boot from a fresh install or live medium, real laptop hardware, bookworm, forky and the Quark editions.

No changelog entry yet: the top stanza 4.31.7-a1 is already published, so this change needs a new version before it can reach users. The unpublished stacked q4os-base in the task dirs carries it as 4.31.11-a1. Delete this file after a fresh install test at the next publish round.
