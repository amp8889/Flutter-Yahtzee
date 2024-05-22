import 'package:flutter/material.dart';
import 'package:mp2/models/dice.dart';
import 'package:mp2/models/scorecard.dart';

class Yahtzee extends StatefulWidget {
  const Yahtzee({Key? key}) : super(key: key);

  @override
  _YahtzeeState createState() => _YahtzeeState();
}

class _YahtzeeState extends State<Yahtzee> {
  final Dice dice = Dice(5); 
  int rollsLeft = 3;
  final ScoreCard scoreCard = ScoreCard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aidan Pavlik - Yahtzee'),
      ),
      body: Container(
        width: 1280,
        height: 720,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  dice.values.length,
                  (index) => DiceWidget(
                    value: dice[index]!,
                    isHeld: dice.isHeld(index),
                    onTap: () {
                      setState(() {
                        dice.toggleHold(index);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: rollsLeft > 0
                    ? () {
                        setState(() {
                          dice.roll();
                          rollsLeft--;
                        });
                      }
                    : null,
                child: Text(rollsLeft > 0 ? 'Roll Dice ($rollsLeft left)' : 'Reset Dice'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: rollsLeft == 0 && !scoreCard.completed
                    ? () {
                        _showCategoryDialog(context);
                      }
                    : null,
                child: const Text('Register Score'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    dice.clear();
                    rollsLeft = 3;
                    scoreCard.clear();
                  });
                },
                child: const Text('Reset Game'),
              ),
              const SizedBox(height: 10),
              if (scoreCard.completed)
                Text(
                  'Game Over!\nTotal Score: ${scoreCard.total}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildScoreCardWidget(),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: buildTotalScore(scoreCard: scoreCard),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCardWidget() {
    return Column(
      children: [
        const Text(
          'Score Card',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        for (var category in ScoreCategory.values.take(6))
          ListTile(
            title: Text(category.name),
            subtitle: Text(
              scoreCard[category] != null
                  ? 'Score: ${scoreCard[category]}'
                  : 'Not selected',
            ),
            tileColor: scoreCard[category] != null ? Colors.grey : null,
          ),
      ],
    );
  }

  void _showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a category'),
          content: Column(
            children: [
              for (var category in ScoreCategory.values)
                if (scoreCard[category] == null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        scoreCard.registerScore(category, dice.values);
                        dice.clear();
                        rollsLeft = 3;
                        Navigator.pop(context); 
                      });
                    },
                    child: Text(category.name),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class buildTotalScore extends StatelessWidget {
  const buildTotalScore({
    super.key,
    required this.scoreCard,
  });

  final ScoreCard scoreCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Score',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '${scoreCard.total}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        for (var category in ScoreCategory.values.skip(6))
          ListTile(
            title: Text(category.name),
            subtitle: Text(
              scoreCard[category] != null
                  ? 'Score: ${scoreCard[category]}'
                  : 'Not selected',
            ),
            tileColor: scoreCard[category] != null ? Colors.grey : null,
          ),
      ],
    );
  }
}

class DiceWidget extends StatelessWidget {
  final int value;
  final bool isHeld;
  final VoidCallback onTap;

  const DiceWidget({
    required this.value,
    required this.isHeld,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isHeld ? Colors.orange : null,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$value',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
