# SeismicityDiary

## ~/projects/SeismicityDiary

*SeismicityDiary.xlsx* is a spreadsheet used to make notes on seismic events.

Yellow highlighting marks entries that have not been fully checked.

## Plots

* Plots for events are stored in *./plots*.
* Plots for strings are stored in *~/Projects/Seismicity/VT_strings/data*.
* Plots for swarmettes are stored in *~/Projects/Seismicity/MSS1_swarmettes*.


## ID

A universal ID is used in file and folder names to identify events.

It uses one of these formats
```
yyyymmdd-hhmm
yyyymmdd-hhmmss
```
The latter is used when events are close together and IDs would not be unique.

The ID does not change when the time of the event changes.


## Sheets

### Strings, StringKeys

* Lists all strings and swarms.
* Described in *MVOM_015-Processing_VT_Strings.pdf*.

### Events

* Lists all seismic events.
* Fields are similar to those in *Strings* sheet, except for the following:

| Field | Contents |
| ----- | ------------------------- |
| Trig | Did the event trigger in earthworm? |
| Duration | Duration of the event in s, m or h. |
| S-P (s) | S minus P time. |
| FirstStation | Station with first arrival. |
| RecordedOn | Stations that recorded a signal, sometimes in order of arrival or signal size. |
| ROD__ | Is event in ROD__ SEISAN database? |
| FPS | Was fault-plane solution obtained? |
| TImeRef | *otime* if time of the event is the origin time instead of the first arrival time. |
| M | Magnitude |
| Conf | Was event confirmed by non-seismic data? |

### WeeklyCounts

* Counts of event types in weekly report.
* An LP/RF would be counted in both the *LP* and *rockfall* counts.

### MSS1Counts

* Counts of small events on MSS1.
* Abandoned on 2024-02-09

## Scripts

Scripts to extract information from *SeismicityDiary.xlsx* into text files and an html file for access in *notWebobs*. The last includes links to all the plots for each event or string.


### diary2doit.pl

* Extracts information from *SeismicityDiary* files to create commands to run *getnPlot* for every event.
* Should be used as part of a pipe, ie
```
$ /extractFromSpreadsheet.pl | grep Irish | diary2doit.pl > doit.sh
```

### extractFromSpreadsheets.pl

* Extracts key information from the spreadsheet *SeismicityDiary.xlsx* to text files.
* Creates html file for *notWebobs*: http://webobs.mvo.ms:8080/SeismicityDiary.html.
* Creates *doIt.sh* which should **never** be run in its entirity.

### updateLists

* Runs *extractFromSpreadsheets.pl* then uses *grep* to create text files.
* Runs once an hour as a cronjob on *opsproc3*.

## cron

*rsync* is used to synchronise all the plot files referenced by *SeismicityDiary.html* on *opsproc3* with *notWebobs*.
```
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
