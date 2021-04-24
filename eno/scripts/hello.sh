#!/bin/bash
if [[ "$ENO_SENDER" != "" ]]; then
   PREFIX="${ENO_SENDER}, "
else
   PREFIX=""
fi

MSG=$(echo "You're an awesome friend.
You're a gift to those around you.
You're a smart cookie.
You are awesome!
You have impeccable manners.
I like your style.
You have the best laugh.
I appreciate you.
You are the most perfect you there is.
You are enough.
You're strong.
Your perspective is refreshing.
I'm grateful to know you.
You light up the room.
You deserve a hug right now.
You should be proud of yourself.
You're more helpful than you realize.
You have a great sense of humor.
You've got an awesome sense of humor!
You are really courageous.
Your kindness is a balm to all who encounter it.
You're all that and a super-size bag of chips.
On a scale from 1 to 10, you're an 11.
You are strong.
You're even more beautiful on the inside than you are on the outside.
You have the courage of your convictions.
I'm inspired by you.
You're like a ray of sunshine on a really dreary day.
You are making a difference.
Thank you for being there for me.
You bring out the best in other people.
Your ability to recall random factoids at just the right time is impressive.
You're a great listener.
How is it that you always look great, even in sweatpants?
Everything would be better if more people were like you!
I bet you sweat glitter.
You were cool way before hipsters were cool.
That color is perfect on you.
Hanging out with you is always a blast.
You always know -- and say -- exactly what I need to hear when I need to hear it.
You help me feel more joy in life.
You may dance like no one is watching, but everyone is watching because you are an amazing dancer!
Being around you makes everything better!
When you say, \"I meant to do that,\" I totally believe you.
When you're not afraid to be yourself is when you are most incredible.
Colors seem brighter when you're around.
You're more fun than a ball pit filled with candy. (And seriously, what could be more fun than that?)
That thing you don't like about yourself is what makes you so interesting.
You're wonderful.
You have cute elbows. For reals!
Jokes are funnier when you tell them.
You're better than a triple-scoop ice cream cone. With sprinkles.
When I'm down you always say something encouraging to help me feel better.
You are really kind to people around you.
You're one of a kind!
You help me be the best version of myself.
If you were a box of crayons, you'd be the giant name-brand one with the built-in sharpener.
You should be thanked more often. So thank you!!
Our community is better because you're in it.
Someone is getting through something hard right now because you've got their back.
You have the best ideas.
You always find something special in the most ordinary things.
Everyone gets knocked down sometimes, but you always get back up and keep going.
You're a candle in the darkness.
You're a great example to others.
Being around you is like being on a happy little vacation.
You always know just what to say.
You're always learning new things and trying to better yourself, which is awesome.
If someone based an Internet meme on you, it would have impeccable grammar.
You could survive a Zombie apocalypse.
You're more fun than bubble wrap.
When you make a mistake, you try to fix it.
You're great at figuring stuff out.
Your voice is magnificent.
The people you love are lucky to have you in their lives.
You're like a breath of fresh air.
You make my insides jump around in the best way.
You're so thoughtful.
Your creative potential seems limitless.
Your name suits you to a T.
Your quirks are so you -- and I love that.
When you say you will do something, I trust you.
Somehow you make time stop and fly at the same time.
When you make up your mind about something, nothing stands in your way.
You seem to really know who you are.
Any team would be lucky to have you on it.
In high school I bet you were voted \"most likely to keep being awesome.\"
I bet you do the crossword puzzle in ink.
Babies and small animals probably love you.
If you were a scented candle they'd call it Perfectly Imperfect (and it would smell like summer).
There is ordinary, and then there's you.
You are someone's reason to smile.
You are even better than a unicorn, because you're real.
How do you keep being so funny and making everyone laugh?
You have a good head on your shoulders.
Has anyone ever told you that you have great posture?
The way you treasure your loved ones is incredible.
You're really something special.
Thank you for being you.
You are a joy.
You are a wonderful part of our family.
You are excellent.
You are so good at this.
You are such a blessing to me.
You are such a leader at school.
You are worth so much to me.
You brighten my life.
You can do anything you put your mind to.
You color my world.
You do things with excellence.
You encourage me.
You have incredible insight.
You have my heart.
You impact me every day.
You love me well.
You love your friends well.
You make a difference.
You make gray skies disappear.
You make me smile.
You make memories sweeter.
You make my days sweeter.
You matter to me.
You put others first.
You rock.
You set a great example.
You shine every day.
You’re a great chatter. I am a fan of yours.
You’re a great leader.
You’re a great bot user.
You’re a team player.
You’re amazing.
You’re artistic.
You’re athletic.
You’re awesome.
You’re beautiful.
You’re compassionate.
You’re creative.
You’re delightful.
You’re doing great things.
You’re fantastic.
You’re fun.
You’re handsome.
You’re helpful.
You’re incredible.
You’re inspiring.
You’re kind.
You’re marvelous.
You’re nice to others.
You’re one of a kind.
You’re outstanding.
You’re positive.
You’re radiant.
You’re smart.
You’re so fun to play with.
You’re so fun-loving.
You’re so hopeful.
You’re so refreshing.
You’re so respectful.
You’re so special.
You’re so strong.
You’re so trustworthy.
You’re the best.
You’re the light of my life.
You’re thoughtful.
You’re tremendous.
You’re unbelievable.
You’re unique.
You have great dreams.
You have great ideas.
You make me so proud.
You win me over every day.
You’re intelligent.
You’re interesting.
You’re talented.
I’m so glad you’re mine." | shuf -n1)

echo "${PREFIX}$MSG"

# EOF
