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
Parse the entries to provide a YAML output with the data.
ALWAYS output only the YAML documents without the surrounding code fence.
NEVER add the backticks around the YAML output.
The output should be directly usable as a YAML file.
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
examples:
  - word: 土地
    reading: トチ
    meaning: ziemia; posiadłość ziemska; region
    related:
      - word: 土地の
        reading: トチの
        meaning: miejscowy, lokalny
sentences:
  - Watashi wa Pōrandojin desu.
  - Kono fune no jin'in wa nannin desu ka.

If an example uses an underscore, refer to the previous one, fill it in the underscore and nest it user the previous example, like this:

土地　トチ　...
＿の　　　　...

becomes

examples:
  - word: 土地
    reading: トチ
    meaning: ziemia; posiadłość ziemska; region
    related:
      - word: 土地の
        reading: トチの
        meaning: miejscowy, lokalny

Do not list it as a separate entry. Nest it inside the `related` list in the previous entry. Reuse the base word and the reading, but don't use additional spaces in the readings.

If there's any additional handwriting visible in the image, ignore it and parse only the printed text.

Some kun'youmi readings contain a dot – preserve the dot, since it represent a suffix. For example, "ちい・さい".

Antonyms are represented with the ⇔ arrow, and synonyms with the ⇒ arrow.

Always include the list of sentences.

ALWAYS output only the YAML documents without the surrounding code fence.
NEVER add the backticks around the YAML output.
The output should be directly usable as a YAML file.''';
