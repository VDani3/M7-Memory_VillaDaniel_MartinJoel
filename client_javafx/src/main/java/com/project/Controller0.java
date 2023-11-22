package com.project;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.StackPane;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Controller0 {

    @FXML
    private GridPane boardPane;

    private ImageView firstCard = null;
    private boolean canSelect = true;

    private List<String> imageNum = new ArrayList<>();
    private List<String> hiddenList = new ArrayList<>();

    private AppData appData;

    @FXML
    private void sortir(ActionEvent event) {
        UtilsViews.setViewAnimating("ViewLogin");
        appData.disconnectFromServer();
        System.out.println("Salir");
    }

    @FXML
    private void initialize() {
        appData = AppData.getInstance();

        imageNum = generateImageNum();
        hiddenList = generateHiddenList();
        
        System.out.println(imageNum);
        int count = 0;
        for (int col = 0; col < 4; col++) {
            for (int row = 0; row < 4; row++) {
                ImageView imageView = new ImageView(getClass().getResource("/images/card.png").toString());
                imageView.setFitWidth(70);
                imageView.setFitHeight(80);
                imageView.setId(Integer.toString(count));
                imageView.setUserData((imageNum.get(count)).toString());
                count++;
                imageView.setOnMouseClicked(event -> cardListener(event));
                StackPane stackPane = new StackPane(imageView);
                boardPane.add(stackPane, row, col);
            }
        }
    }

    private List<String> generateHiddenList() {
        List<String> list = new ArrayList<>();
        for (int i=0;i<imageNum.size();i++) {
            list.add("hidden");
        } 
        return list;
    }

    private List<String> generateImageNum() {
        List<String> list = new ArrayList<>(); 
        for (int i = 0; i < 8; i++) {
            String num = String.valueOf(i);
            list.add(num);
            list.add(num);
        }
        Collections.shuffle(list);
        return list;
    }

    public void cardListener(MouseEvent event) {
        if (!canSelect){
            System.out.println("aaaa");
            return;
        } 
        //System.out.println(hiddenList);
        
        ImageView clickedCard = (ImageView) event.getSource();
        int clickedCardID = Integer.valueOf(clickedCard.getId());

        if (hiddenList.get(clickedCardID).equals("hidden")) {
            Image image = new Image(getClass().getResource("/images/card"+clickedCard.getUserData()+".png").toString());
            clickedCard.setImage(image);

            hiddenList.set(clickedCardID, imageNum.get(clickedCardID).toString());
        } else {
            return;
        }

        if (firstCard == null) {
            firstCard = clickedCard; 
            
        } else {
            if (firstCard.getUserData().equals(clickedCard.getUserData())) {
                // Las cartas son iguales
                System.out.println("Emparejadas!");

                firstCard = null;
            } else {
                // Las cartas no son iguales
                System.out.println("No emparejadas!");
                canSelect = false; 

                hiddenList.set(clickedCardID, "hidden");
                hiddenList.set(Integer.valueOf(firstCard.getId()), "hidden");

                new Thread(() -> {
                    try { Thread.sleep(1000); } catch (InterruptedException e) { e.printStackTrace(); } 

                    Image img = new Image(getClass().getResource("/images/card.png").toString());
                    firstCard.setImage(img);

                    try { Thread.sleep(200); } catch (InterruptedException e) { e.printStackTrace(); } 

                    clickedCard.setImage(img);

                    firstCard = null;
                    canSelect = true; 
                }).start();
            }
        }
        checkWinner();
    }

    private void checkWinner() {
        // TODO
    }
}
