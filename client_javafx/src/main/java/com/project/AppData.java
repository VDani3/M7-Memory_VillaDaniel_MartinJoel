package com.project;

import java.net.URI;
import java.net.URISyntaxException;

import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONObject;

import com.project.AppSocketsClient.OnCloseObject;

public class AppData {
    private static final AppData INSTANCE = new AppData();
    private AppSocketsClient socketClient;
    private String ip = "localhost";
    private String port = "8888";
    private ConnectionStatus connectionStatus = ConnectionStatus.DISCONNECTED;
    
    public enum ConnectionStatus {
        DISCONNECTED, DISCONNECTING, CONNECTING, CONNECTED
    }
    
    private AppData() {
    }

    public static AppData getInstance() {
        return INSTANCE;
    }

    public void connectToServer() {
        try {
            URI location = new URI("ws://" + ip + ":" + port);
            socketClient = new AppSocketsClient(
                    location,
                    (ServerHandshake handshake) ->  { this.onOpen(handshake);},
                    (String message) ->             { this.onMessage(message); },
                    (OnCloseObject closeInfo) ->    { this.onClose(closeInfo); },
                    (Exception ex) ->               { this.onError(ex); }
            );
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }
    }

    private void onOpen (ServerHandshake handshake) {
        System.out.println("Handshake: " + handshake.getHttpStatusMessage());
        connectionStatus = ConnectionStatus.CONNECTED; 
    }

    private void onMessage(String message) {
        JSONObject data = new JSONObject(message);

        if (connectionStatus != ConnectionStatus.CONNECTED) {
            connectionStatus = ConnectionStatus.CONNECTED;
        }

        String type = data.getString("type");
        switch (type) {
            case "???????":
                // TODO
                break;
            default:
                System.out.println("Message from " + data.getString("from") + ":" + data.getString("value") + "\n");
                break;
        }
        if (connectionStatus == ConnectionStatus.CONNECTED) {
            
        }
    }

    public void onClose(OnCloseObject closeInfo) {
        connectionStatus = ConnectionStatus.DISCONNECTED;
        UtilsViews.setViewAnimating("ViewLogin");
    }

    public void onError(Exception ex) {
        System.out.println("Error: " + ex.getMessage());
    }



    public String getIp() {
        return ip;
    }

    public String setIp (String ip) {
        return this.ip = ip;
    }

    public String getPort() {
        return port;
    }

    public String setPort (String port) {
        return this.port = port;
    }
}
