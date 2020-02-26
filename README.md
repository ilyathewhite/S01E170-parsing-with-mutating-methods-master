# Comparison between manual parsing and parser combinators.

This is the code that accompanies Swift Talk Episode 170: [Parsing with Mutating Methods](https://talk.objc.io/episodes/S01E170-parsing-with-mutating-methods). I added a parser combinators implementation based on the Point-Free series.

File ParseCSVTests has testPerformance() which you can run with parseAlt() (fastest), parseCSV() (refactored for readability), and parseWithCombinators() which is 9 times slower than parseAlt().
