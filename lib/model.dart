import 'package:google_generative_ai/google_generative_ai.dart';

GenerativeModel createModel({required String apiKey}) => GenerativeModel(
  model: 'gemini-2.0-flash',
  apiKey: apiKey,
  generationConfig: GenerationConfig(
    temperature: 0,
    topK: 40,
    topP: 0.95,
    responseMimeType: 'text/plain',
  ),
  systemInstruction: Content.system(_system),
);

const _system = '''
You'll be given entries from a Kanji textbook.
Parse each entry to create one YAML document with the data as the output.
Use all attached images. Each image contains one dictionary entry.
Output YAML documents separated with ---.
This is an example of the schema:

id: 10
kanji: 九
strokes: 2
radical: 乙
synonyms:
  - 八
antonyms:
  - 一
readings:
  onyomi:
    - キュウ
    - ク
  kunyomi:
    - ここの
    - ここの・つ
words:
  - word: 土地
    reading: トチ
    meaning: ziemia; posiadłość ziemska; region
    related:
      - word: ＿の
        meaning: miejscowy, lokalny
sentences:
  - Watashi wa Pōrandojin desu.
  - Kono fune no jin'in wa nannin desu ka.

If a word uses an underscore, nest it user the previous word, like this:

土地　トチ　ziemia; posiadłość ziemska; region
＿の　　　　miejscowy, lokalny

becomes

words:
  - word: 土地
    reading: トチ
    meaning: ziemia; posiadłość ziemska; region
    related:
      - word: ＿の
        meaning: miejscowy, lokalny

NEVER include words containing the underscore (＿) in the main list.

Do not list it as a separate entry. Nest it inside the `related` list in the previous entry. Reuse the base word and the reading, but don't use additional spaces in the readings.

If there's any additional handwriting visible in the image, ignore it and parse only the printed text.

Some kun'youmi readings contain a dot – preserve the dot, since it represent a suffix. For example, "ちい・さい".

Antonyms are represented with the ⇔ arrow, and synonyms with the ⇒ arrow.

Always include the list of sentences.

ALWAYS output only the YAML documents without the surrounding code fence.
NEVER add the backticks around the YAML output.
The output should be directly usable as a YAML file.

If the content contains quotation marks, escape them.

Always make sure that the output contains exactly the same number of documents as the provided images.
''';
