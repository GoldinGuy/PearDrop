class PearPanel {
  bool sharing = true, receiving = false;

  setPanelSharing() {
    sharing = true;
    receiving = false;
  }

  setPanelReceiving() {
    sharing = false;
    receiving = true;
  }
}
