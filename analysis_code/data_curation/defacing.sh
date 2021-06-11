sudo docker run -i --rm \
           -v ~/DATA/2_Analysis_Folder/PIVOTAL/FeedBES/BIDS:/bids_dataset \
           peerherholz/bidsonym \
           /bids_dataset  group --deid pydeface \
           --brainextraction bet --bet_frac 0.5