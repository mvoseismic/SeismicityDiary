# SeismicityDiary

Scripts to extract information from *SeismicityDiary.xlsx* into text files and an html file for access in *notWebobs*. The last includes links to all the plots for each event or string.

## extractFromSpreadsheets.pl

* Extracts key information from the spreadsheet *SeismicityDiary.xlsx* to text files.
* Creates html file for *notWebobs*: http://webobs.mvo.ms:8080/SeismicityDiary.html.
* Creates *doIt.sh* which should **never** be run in its entirity.

## updateLists

* Runs *extractFromSpreadsheets.pl* then uses *grep* to create text files.
* Runs once an hour as a cronjob on *opsproc3*.

## cron

*rsync* is used to synchronise all the plot files referenced by *SeismicityDiary.html* on *opsproc3* with *notWebobs*.
```
# Seismicity diary
# Seismicity diary
15 * * * * cd /home/seisan/projects/SeismicityDiary; ./updateLists >/dev/null 2>&1; scp SeismicityDiary.html webobs@webobs:/var/www/html/; scp SeismicityDiary-*.txt webobs@webobs:/var/www/html/SeismicityDiary/
4 * * * * rsync -a /home/seisan/projects/Seismicity/VT_strings/data/all_plots/* webobs@webobs:/var/www/html/plots/strings >/dev/null 2>&1
6 * * * * rsync -a /home/seisan/projects/SeismicityDiary/plots/* webobs@webobs:/var/www/html/plots/events/ >/dev/null 2>&1
8 * * * * rsync -a --exclude 'tmp' /home/seisan/projects/Seismicity/VT_strings/data/heli_plots/* webobs@webobs:/var/www/html/plots/strings >/dev/null 2>&1
```

## Author

Roderick Stewart, Dormant Services Ltd

rod@dormant.org

https://services.dormant.org/

## Version History

* 1.0-dev
    * Working version

## License

This project is the property of Montserrat Volcano Observatory.
