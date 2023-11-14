package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.TextField;

public class ControlerLogin {
    private AppData appData;

    @FXML
    private TextField ipTF, portTF, nameTF;

    public void initialize(){
        appData = AppData.getInstance();
    }

    @FXML
    private void connectToWS(){
        appData.setIp(ipTF.getText());
        appData.setPort(portTF.getText());
        appData.connectToServer();
    }
}
