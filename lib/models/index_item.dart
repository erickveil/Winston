/// A model class that indexes a card image with its json name.
class IndexItem {

  final String imagePath; 
  final String jsonName;  

  IndexItem({
    required this.imagePath, 
    required this.jsonName
  });
}