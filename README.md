# FABL
Experiment for real-time human behavior awareness by Feature And Body-part Learning (FABL) on real-world baxter interaction application, see
http://hcr.mines.edu/code/FABL.html

### Data format:
The dataset used in the experiment is compressed as dataset.zip. The data format of each .txt file is shown as follows:

's1_a2_e3.txt' stores the data when performing activity 2 by subject 1 for the third time. There are 5 columns in the data file

|     Frame \#  | Skeletal joint \# |     x cooridnate      |     y coordinate      |     z coordinate      |    
| ------------- | -------------     |     -------------     |     -------------     |     -------------     |
|     1         |     1             |     1.43              |     0.03              |     0.32              |
|     1         |     2             |     1.41              |     0.03              |     0.10              |
|     ...       |     ...           |     ...               |     ...               |     ...               |
|     47        |     15            |     0.89              |     -0.36             |     -1.01             |


### Usage:

1. Uncompress dataset.zip to the project;

2. Run 'feature_extraction.m' to extract features for all human activity data;

3. Run 'train_test_generation.m' to split training and testing;

4. Run 'main.m' to get the final results.

### Cite:
If you use our method and/or codes, please cite our paper
```
@INPROCEEDINGS { han2017simultaneous,
      AUTHOR    = {Fei Han AND Xue Yang AND Christopher Reardon AND Yu Zhang AND Hao Zhang},
      TITLE     = {Simultaneous Feature and Body-Part Learning for Real-Time Robot Awareness of Human Behaviors},
      BOOKTITLE = {IEEE International Conference on Robotics and Automation (ICRA)},
      YEAR      = {Submitted}
  }
```
