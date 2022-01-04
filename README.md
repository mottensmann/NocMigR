
## NocMigR

------------------------------------------------------------------------

This package is in a *very* preliminary state and provides some
workflows for processing large sound files (e.g., `NocMig`, `NFC`,
`AudioMoth`), with a main emphasis on automatise the detection of events
(i.e., extracting calls with time-stamps) that can be easily reviewed in
[Audacity](https://www.audacityteam.org/).

All major computation steps are carried out by sophisticated libraries
called in the background. Including:

-   **R packages**

-   [bioacoustics](https://cran.r-project.org/package=bioacoustics)

-   [tuneR](https://cran.r-project.org/package=tuneR)

-   [seewave](https://cran.r-project.org/package=seewave)

-   [Warbler](https://cran.r-project.org/package=warbleR)

-   **python packages**

-   [audioop](https://docs.python.org/3/library/audioop.html)

-   [pydub](https://github.com/jiaaro/pydub)

To install the package, use …

``` r
devtools::install_github("mottensmann/NocMigR")
```

## Examples

------------------------------------------------------------------------

Load the package once installed …

``` r
library(NocMigR)
```

### Load example audio

The package contains an example file captured using an
[AudioMoth](https://www.openacousticdevices.info/) recorder. To reduce
file size, a segment of five minutes was downsampled to 44.1 kHz and
saved as 128 kbps mp3 file.

``` r
## get path to test_audio.mp3
path <- system.file("extdata", "20211220_064253.mp3", package = "NocMigR")
## create temp folder
dir.create("example")
## copy to test_folder
file.copy(path, "example")
## convert to wav
bioacoustics::mp3_to_wav("example/20211220_064253.mp3", delete = T)
```

Plot spectro …

``` r
audio <- tuneR::readWave("example/20211220_064253.wav")
bioacoustics::spectro(audio, FFT_size = 2048, flim = c(0, 5000))
```

<img src="inst/README-unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

### 1.) `rename_recording`

Naming files using a string that combines the recording date and
starting time (`YYYYMMDD_HHMMSS`) is good practice to store and analyse
the audio data. By default, recorders such as the
[AudioMoth](https://www.openacousticdevices.info/) follow this
conventions, whereas popular field recorders (e.g., Olympus LS, Tascam
DR or Sony PCM) use different, rather uninformative naming schemes.
Usually the relevant information to construct a proper date\_time string
is embedded in the meta data of the recording (accessible using
`file.info()`). *Note*, recorders may differ in the routines to save
audio to a memory card. For instance, long recording sessions using an
Olympus LS-3 will create multiple files, all of which share the same
creation and modification times (with respect to the first recording).
By contrast, the Sony PCM-D100 saves files individuals (i.e, all have
unique ctimes and mtimes).

``` r
## only simulate output as file is already labelled
rename_recording(path = "example", format = "wav", recorder = "Sony PCM-D100", simulate = T)
#>                                        old.name  seconds                time
#> example/20211220_064253.wav 20211220_064253.wav 300.0686 2022-01-04 02:04:22
#>                                        new.name
#> example/20211220_064253.wav 20220104_020422.wav
```

### 2.) `split_wave`: Divide long recordings

Function is in a *beta-state* and allows to split long audio recordings
into smaller chunks for processing with
`bioacoustics::threshold_detection`. *To keep the time information,
files are written with the corresponding starting time*

``` r
## split in segments
split_wave(file = "20211220_064253.wav", # which file
           path = "example", # where to find it
           segment = 30, # cut in 30 sec segments
           downsample = 32000) # resample at 32000
#> 
#> Downsampling of 20211220_064253.wav to 32000 Hz...   done
#> Split ...

## show files
list.files("example/split/")
#>  [1] "20211220_064253.WAV" "20211220_064323.WAV" "20211220_064353.WAV"
#>  [4] "20211220_064423.WAV" "20211220_064453.WAV" "20211220_064523.WAV"
#>  [7] "20211220_064553.WAV" "20211220_064623.WAV" "20211220_064653.WAV"
#> [10] "20211220_064723.WAV" "20211220_064753.WAV"
## delete folder
unlink("example/split", recursive = TRUE)
```

### 3.) `find events`: Identify signals of interest

This functions is a wrapper to `bioacoustics::threshold_detection()`
aiming at extracting calls based on the signal to noise ratio and
target-specific assumptions about approximate call frequencies and
durations. Check `?bioacoustics::threshold_detection()` for details.
*For long recordings (i.e, several hours) it makes sense to run on
segments as created before to avoid memory issues. Here we use the demo
sound file*

``` r
## run detection threshold algorithm
TD <- find_events(wav.file = "example/20211220_064253.wav",
                  threshold = 8, # Signal-to-noise ratio in db
                  min_dur = 20, # min length in ms
                  max_dur = 300, # max length in ms
                  LPF = 5000, # low-pass filter at 500 Hz
                  HPF = 1000) # high-pass filter at 4 kHz

## Review events 
head(TD$data$event_data[,c("filename", "starting_time", "duration", "freq_max_amp")])
#>              filename starting_time  duration freq_max_amp
#> 1 20211220_064253.wav  00:00:46.576 168.34467     1477.762
#> 2 20211220_064253.wav  00:00:47.045 190.11338     1646.544
#> 3 20211220_064253.wav  00:00:47.887 116.82540     1790.127
#> 4 20211220_064253.wav  00:00:48.277 150.92971     1827.046
#> 5 20211220_064253.wav  00:00:48.774  91.42857     1964.311
#> 6 20211220_064253.wav  00:00:49.332  21.04308     2264.046

## display spectrogram based on first six events
audio <- tuneR::readWave("example/20211220_064253.wav",
                         from = 46,
                         to = 50,
                         units = "seconds")
bioacoustics::spectro(audio, FFT_size = 2048, flim = c(0, 5000))
```

<img src="inst/README-unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

In addition to the output shown above, a file with labels for reviewing
events in `Audacity` is created (wrapping `seewave::write.audacity()`).

<div class="figure" style="text-align: center">

<img src="inst/extdata/screenshot_1.PNG" alt="Screenshot: Audacity raw labels" width="900px" />
<p class="caption">
Screenshot: Audacity raw labels
</p>

</div>

### 4.) `extract_events`: Subset original recording file

Refines the output of `find_events` by first adding a buffer (default 1
second on both sides of the event) and subsequently merging overlapping
selections to simplify the output. Additionally, allows to filter based
on expected frequencies (i.e., checks maximum amplitude frequency is
within the frequency band defined by HPF:LPF)

``` r
df <- extract_events(threshold_detection = TD, path = "example", format = "wav", 
    LPF = 4000, HPF = 1000, buffer = 1)
#> 6 selections overlapped
```

Display refined events …

``` r
## display spectrogram based on first six events
audio <- tuneR::readWave("example/20211220_064253.wav", from = df$from, to = df$to, 
    units = "seconds")
bioacoustics::spectro(audio, FFT_size = 2048, flim = c(0, 5000))
```

<img src="inst/README-unnamed-chunk-11-1.png" style="display: block; margin: auto;" />

Output reviewed in `Audacity`

<div class="figure" style="text-align: center">

<img src="inst/extdata/screenshot_2.PNG" alt="Screenshot: Audacity refined label" width="900px" />
<p class="caption">
Screenshot: Audacity refined label
</p>

</div>

### 5.) `batch_process`: Execute several algorithms in batch mode

Run all above steps in one go and for all files within a folder

``` r
batch_process(path = "example", format = "wav", segment = NULL, downsample = NULL, 
    SNR = 8, species = "Glaucidium passerinum", rename = FALSE)
#> Start processing:     2022-01-04 02:04:43 
#> Search for events using Glaucidium passerinum as template ...
#> done
#> Extract events ... 
#> 8 selections overlapped
#> done
#> Finished processing:  2022-01-04 02:04:44 
#>  Run time:    1.72 seconds
#> In total 2 events for template Glaucidium passerinum detected
#>              filename    from        to       starting_time   event
#> 1 20211220_064253.wav  45.576  50.38133 2021-12-20 06:43:39  46.576
#> 2 20211220_064253.wav 152.434 156.35420 2021-12-20 06:45:26 153.434
```

------------------------------------------------------------------------

``` r
## clean-up
unlink("example", recursive = TRUE)
```
