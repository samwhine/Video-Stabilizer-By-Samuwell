# Video Stabilizer (Batch)

A simple Windows batch script that stabilizes shaky handheld footage using FFmpeg's `vidstab` filter. No gimbal and no gyro data needed. Drop it into a folder of clips, double-click, pick a mode, and get stabilized copies in a separate folder.

Your original files are never modified.

## Features

- **Batch processing**: stabilizes every video in the folder in one run
- **Non-destructive**: results go to a new `Stabilized Video` folder
- **Three stabilization modes**: from gimbal-smooth to minimal cropping
- **Three quality levels**: including a near-original option for color grading
- **Folder-agnostic**: works in any folder, whatever it is named
- **Safe to re-run**: clips that already have a result for the chosen mode and quality are skipped
- **Audio preserved**: audio is copied without re-encoding, and metadata is carried over

## Requirements

- Windows
- [FFmpeg](https://ffmpeg.org/download.html) available in your `PATH`, **built with `libvidstab`**

The "full" builds (for example `ffmpeg-release-full` from [gyan.dev](https://www.gyan.dev/ffmpeg/builds/)) include it. To check your build:

```
ffmpeg -filters | findstr vidstab
```

You should see `vidstabdetect` and `vidstabtransform` in the output. If not, install a full build.

## Usage

1. Copy `Stabilize.bat` into the folder that contains your videos.
2. Double-click it.
3. Choose a stabilization mode (1-3).
4. Choose an output quality (1-3).
5. Wait for it to finish. Results appear in `Stabilized Video`.

```
cam1/
├── Stabilize.bat
├── clip1.mp4
├── clip2.mp4
└── Stabilized Video/          <- created automatically
    ├── clip1_recommended_max.mp4
    └── clip2_recommended_max.mp4
```

Only videos directly inside the folder are processed. Subfolders are ignored, so copy the script into each folder you want to process.

Supported input formats: `.mp4` `.mov` `.mkv` `.m4v` `.mts` `.avi`. Output is always `.mp4` (H.264).

## Stabilization modes

| Mode | Smoothing | Zoom | Result |
|---|---|---|---|
| 1. Most Stable | 45 | Fixed optimal zoom | Smoothest, gimbal-like look, the most cropping |
| 2. Recommended | 30 | Fixed optimal zoom | Balanced smoothness and cropping |
| 3. Minimum Cut | 10 | Adaptive zoom (slow) | Least cropping, lighter stabilization |

Stabilization crops the edges of the frame to hide the camera movement. Higher smoothing means a larger crop. In Minimum Cut mode the zoom adapts to each moment, which can occasionally look like a slight "breathing" effect during big movements. If that bothers you, use Recommended.

## Output quality

| Level | CRF | Best for |
|---|---|---|
| 1. Maximum | 8 | Closest to the original, ideal if you plan to color grade. Largest files |
| 2. High | 12 | Very high quality with smaller files |
| 3. Balanced | 15 | Good quality, smallest files |

Lower CRF means higher quality and a larger file. Camera footage often has a very high bitrate, so output files can be much smaller than the originals even at high quality, because x264 is more efficient than in-camera encoding.

## Output naming

```
<original name>_<mode>_<quality>.mp4
```

Examples: `C0086_most-stable_max.mp4`, `C0086_min-cut_balanced.mp4`.

Because the mode and quality are in the filename, you can try different combinations on the same clip and compare them without overwriting anything.

## How it works

The script runs a two-pass stabilization with FFmpeg:

1. **Pass 1 (`vidstabdetect`)**: analyzes camera motion across the whole clip.
2. **Pass 2 (`vidstabtransform`)**: smooths the motion path and re-renders the video.

Final encoding uses `libx264` with the `slow` preset and `yuv420p` pixel format for wide compatibility.

## Customizing

Open `Stabilize.bat` in a text editor. The mode values live under the `:mode1`, `:mode2`, and `:mode3` labels, and the quality values under `:q1`, `:q2`, and `:q3`:

| Variable | Meaning |
|---|---|
| `SMOOTH` | Number of frames used to smooth the camera path. Higher is smoother but crops more |
| `SHAKINESS` | How shaky the footage is expected to be (1-10) |
| `OPTZOOM` | `1` for a fixed optimal zoom, `2` for adaptive zoom |
| `ZOOMSPEED` | How quickly adaptive zoom changes |
| `CRF` | Encoding quality. Lower is better and larger |
| `PRESET` | x264 speed preset. Slower gives better compression |

## Limitations

- `vidstab` does 2D stabilization (shift and rotation). It does **not** correct rolling shutter ("jello" wobble) or perspective changes. For difficult clips, tools like DaVinci Resolve's Stabilizer or Adobe Warp Stabilizer may give better results.
- Output is always re-encoded, so a small amount of quality loss is unavoidable. Maximum quality makes it very hard to notice.
- Output is 8-bit `yuv420p`. 10-bit or HDR sources will be converted to 8-bit.
- Rendering with the `slow` preset and the detailed motion analysis takes a while on long or high-resolution clips.

## Troubleshooting

**`ffmpeg was not found in PATH`**: install FFmpeg and add its `bin` folder to your system `PATH`, then reopen the script.

**`No such filter: 'vidstabdetect'`**: your FFmpeg build lacks `libvidstab`. Install a full build (see Requirements).

**`No videos found`**: make sure `Stabilize.bat` is in the same folder as your videos, not in a parent folder.

## Author

Made by **Samuel Extehines Heydemans** ([@samwhine](https://github.com/samwhine)).

## License

MIT. Feel free to use, modify, and share.
