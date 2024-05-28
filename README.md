# PotterBassiRunyan2024
 Code used in analyses of neural activity in the study
https://doi.org/10.1101/2023.01.09.523298

See also code that was used to distinguish inhibitory cell types expressing the fluorophores mCherry and tdTomato: https://github.com/RunyanLab/Clustering-Pipeline/tree/main

### Basic details

SOM-Flp x PV-Cre mice expressed GCaMP6f in all neurons, tdTomato in PV neurons, and mCherry in SOM neurons. GCaMP6f was imaged in the posterior parietal cortex (PPC) at 30 Hz while mice voluntarily ran on a spherical treadmill. The clustering pipeline above was used to identify PV and SOM neurons.

The code here was used to analyze the neural activity (GCaMP6f fluorescence changes).

### Figure 1

Code used to plot average fluorescence intensity across imaging wavelengths in the paper.

### Figure 2

Calculating the partial pairwise Pearson correlations for different cell type combinations. The running velocity of the mouse was discounted from the correlation calculation.

### Figure 3

Identify PV, SOM, and Mixed Events (inhibitory neuron events). Plot mean activity of each cell type during these events.

### Figure 4

Run analyses of population activity during different inhibitory neuron event types. 
