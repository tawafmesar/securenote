class NoteModel {
  int? id;
  String? title;
  String? description;
  bool isArchived = false;
  bool isPinned = false;
  String category = 'Work';

  NoteModel(this.title, this.description, {this.id, this.isArchived = false, this.isPinned = false, this.category = 'Work'});

  NoteModel.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
    isArchived = map['isArchived'] == 1;
    isPinned = map['isPinned'] == 1;
    category = map['category'] ?? 'Work';
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isArchived': isArchived ? 1 : 0,
      'isPinned': isPinned ? 1 : 0, 
      'category': category,
    };
  }
}