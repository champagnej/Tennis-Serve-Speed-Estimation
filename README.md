# Tennis-Serve-Speed-Estimation

## Prerequisites:
MATLAB (version R2023b or later)
Image Processing Toolbox
A video clip of a tennis serve in MP4 format (30 fps recommended)

## Project Structure:
Executable files:
Tennis_Ball_Top_single_run.m
  Single-video processing pipeline. Configure the filename and frame_rate variables, then run this script to process one serve clip.
Tennis_Ball_Top_multiple_runs.m
  Batch-processing wrapper. Edit the filenames cell array with paths to multiple .mp4 clips, then run to process sequentially.

## Main supporting functions:
find_ball2.m
  Detects moving clusters (ball candidates) from three consecutive frames using frame differencing, gaussian smoothing, Canny edges, and DBSCAN clustering.
cluster_tracking.m
  Links those clusters frame-to-frame into persistent trajectories, assigning unique IDs and computing per-frame speed and angle metrics.
filter_top_player_cluster.m
  Filters tracked clusters to find the servers motion
get_top_y_values.m
  Selects the frame and pixel coordinates where the server cluster reaches its highest point
find_corners.m
  Detects the four tennis-court corners in a given frame
plot_court_and_points
  Displays the court overlayed with the estimated corners, serve initiation point, and bounce point, as well as the estimated speed and radar-measured speed on a MATLAB figure

## Quick Start
1. Open MATLAB and set Current Folder to project's root directory.
2. For a single clip, open Tennis_Ball_Top_single_run.m
   Change filename to your .mp4 file (you may need to fine tune parameters for best performance)
3. For multiple clips, open Tennis_Ball_Top_multiple_runs.m
   Edit filenames list with your video paths
4. Review outputs by analyzing the generated PNG's with same base name as the inputted video


_For full methodological details, results, and discussion, see my thesis "Tennis Ball Serve Speed Estimation" (May 2025)._
