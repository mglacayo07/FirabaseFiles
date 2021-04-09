//
//  ViewController.swift
//  FirabaseFiles
//
//  Created by Maria Lacayo on 13/03/21.
//

import UIKit
import Firebase
import CoreServices
import FirebaseUI
import FirebaseRemoteConfig

class ViewController: UIViewController{

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var collection: UICollectionView!
    @IBOutlet var button: UIButton!
    
    let storage = Storage.storage()
    var images: [StorageReference] = []
    let placeHolderImage = UIImage(named: "notfound")
    var idImage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "imageCollectionViewCell", bundle: nil)
        collection.register(nib, forCellWithReuseIdentifier: "imageCellXIB")
        
        let isButtonEnabled = RemoteConfig.remoteConfig().configValue(forKey: "isButtonEnabled").boolValue
        
        if !isButtonEnabled{
            button.isEnabled = isButtonEnabled
            button.backgroundColor = .lightGray
        }
        downloadImageFirebase()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
    }
    @IBAction func uploadImage(_ sender: UIButton){
        let userImagePicker = UIImagePickerController() //Abre una vista que permite elegir algun elemento de las fotos
        
        //Implementamos los metodos del controlador
        userImagePicker.delegate = self //Los metodos que vayamos a desarrollar los manejara el ViewController
        userImagePicker.sourceType = .photoLibrary //Cual va a ser mi fuente
        userImagePicker.mediaTypes = ["public.image"] //Arreglo de cadenas de los posibles medios a escoger
        present(userImagePicker, animated: true, completion: nil)
    }
    
    func uploadImageFirebase(imageData: Data){
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images").child("profile").child("userProfile\(idImage).jpg")
        
        //Le decimos que tipo de información queremos subir
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        //MEtodo para subir la información
        imageRef.putData(imageData,metadata: uploadMetaData){
            (metadata,error) in
            if let error = error{
                print("Error \(error.localizedDescription) ")
            }else{
                print("Image metadata: \(String(describing: metadata))")
            }
        }
        
    }
    
    func downloadImageFirebase(){
        let storageRef = storage.reference()
        let imageDowmloadRef = storageRef.child("images/profile/userProfile\(idImage).jpg")
        images.append(imageDowmloadRef)
        
        userImageView.sd_setImage(with: imageDowmloadRef,placeholderImage: placeHolderImage)
        imageDowmloadRef.downloadURL { (url, error) in
            if let error=error{
                print("Error \(error.localizedDescription) ")
            }else{
                print("URL: \(String(describing: url))")
            }
        }
        
        idImage += 1
        collection.reloadData()
    }
}

extension ViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let optimizedImageData = userImage.jpegData(compressionQuality: 0.6){
            uploadImageFirebase(imageData: optimizedImageData)
        }
        picker.dismiss(animated: true, completion: nil)
        //optimizedImageData de la imagen que acabo de escoger vamos a comprimirla a la calidad del 60%
    }
}

extension ViewController: UINavigationControllerDelegate{
    
}

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCellXIB", for: indexPath) as! imageCollectionViewCell
        
        let ref = images[indexPath.item]
        cell.imageViewCell.sd_setImage(with: ref, placeholderImage: placeHolderImage)
        ref.downloadURL { (url, error) in
            if let error=error{
                print("Error \(error.localizedDescription) ")
            }else{
                print("URL: \(String(describing: url))")
            }
        }
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate{
    
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }

}
