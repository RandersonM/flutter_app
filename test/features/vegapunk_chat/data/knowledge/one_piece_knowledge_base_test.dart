import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/vegapunk_chat/data/knowledge/one_piece_knowledge_base.dart';

void main() {
  group('OnePieceKnowledgeBase', () {
    test(
      'getDocumentsForCategories returns all documents if categories is null or empty',
      () {
        final docsNull = OnePieceKnowledgeBase.getDocumentsForCategories(null);
        expect(docsNull.length, equals(OnePieceKnowledgeBase.documents.length));

        final docsEmpty = OnePieceKnowledgeBase.getDocumentsForCategories([]);
        expect(
          docsEmpty.length,
          equals(OnePieceKnowledgeBase.documents.length),
        );
      },
    );

    test(
      'getDocumentsForCategories filters documents by category and normalizes name',
      () {
        // Direct category match
        final characterDocs = OnePieceKnowledgeBase.getDocumentsForCategories([
          'character',
        ]);
        expect(characterDocs.every((d) => d.category == 'character'), isTrue);
        expect(characterDocs, isNotEmpty);

        // Mapped name: "characterDocs"
        final characterDocsMapped =
            OnePieceKnowledgeBase.getDocumentsForCategories(['characterDocs']);
        expect(
          characterDocsMapped.every((d) => d.category == 'character'),
          isTrue,
        );
        expect(characterDocsMapped.length, equals(characterDocs.length));

        // Mapped name: "characters"
        final charactersMapped =
            OnePieceKnowledgeBase.getDocumentsForCategories(['characters']);
        expect(
          charactersMapped.every((d) => d.category == 'character'),
          isTrue,
        );
        expect(charactersMapped.length, equals(characterDocs.length));

        // Multiple categories
        final multipleDocs = OnePieceKnowledgeBase.getDocumentsForCategories([
          'characterDocs',
          'devil_fruit',
        ]);
        expect(
          multipleDocs.every(
            (d) => d.category == 'character' || d.category == 'devil_fruit',
          ),
          isTrue,
        );
        expect(
          multipleDocs.where((d) => d.category == 'character'),
          isNotEmpty,
        );
        expect(
          multipleDocs.where((d) => d.category == 'devil_fruit'),
          isNotEmpty,
        );
      },
    );

    test(
      'getDocumentsForCategories returns empty list if no category matches',
      () {
        final docs = OnePieceKnowledgeBase.getDocumentsForCategories([
          'non_existent_category',
        ]);
        expect(docs, isEmpty);
      },
    );
  });
}
