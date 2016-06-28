//
//  FoodHelper.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "FoodHelper.h"
#import "FoodType.h"

@implementation FoodHelper

static FoodHelper *sharedInstance;

+ (void)initialize {
	static BOOL initialized = NO;
	
	if(!initialized) {
		initialized = YES;
		sharedInstance = [[FoodHelper alloc] init];
	}
}

+ (FoodHelper *)getInstance {
	return sharedInstance;
}

- (FoodType *)getFoodTypeForFoodIdentifier:(NSString *)identifier {
	
	FoodType *foodType = [[FoodType alloc] init];
	
	if ([identifier compare:K_IDENTIFIER_BEANS] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_beans"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Beans";
		foodType.recommendedServingCount = 3.0;
		foodType.servingExample = @"1⁄4 cup of hummus or bean dip, or\n1⁄2 cup cooked beans, split peas, lentils, tofu, or tempeh, or\n1 cup of fresh peas or sprouted lentils";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Black beans, black-eyed peas, butter beans, cannellini beans, chickpeas (also known as garbanzo beans), edamame, english peas, great northern beans, kidney beans, lentils (beluga, french, and red varieties), miso, navy beans, pinto beans, small red beans, split peas (yellow or green), and tempeh"];
		
	} else if ([identifier compare:K_IDENTIFIER_BERRIES] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_berries"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Berries";
		foodType.recommendedServingCount = 1.0;
		foodType.servingExample = @"1⁄2 cup fresh or frozen, or\n1⁄4 cup dried";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Açai berries, barberries, blackberries, blueberries, cherries (sweet or tart), concord grapes, cranberries, goji berries, kumquats, mulberries, raspberries (black or red), and strawberries"];
		
	} else if ([identifier compare:K_IDENTIFIER_OTHER_FRUIT] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_apple"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Other Fruit";
		foodType.recommendedServingCount = 3.0;
		foodType.servingExample = @"1 medium-sized fruit, or\n1 cup cut-up fruit, or\n1⁄4 cup dried fruit";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Apples, dried apricots, avocados, bananas, cantaloupe, clementines, dates, dried figs, grapefruit, honeydew, kiwifruit, lemons, limes, lychees, mangos, nectarines, oranges, papaya, passion fruit, peaches, pears, pineapple, pomegranates, plums (especially black plums), pluots, prunes, tangerines, and watermelon"];
		
	} else if ([identifier compare:K_IDENTIFIER_CRUCIFEROUS] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_cruciferous"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Cruciferous Vegetables";
		foodType.recommendedServingCount = 1.0;
		foodType.servingExample = @"1⁄2 cup chopped, or\n1⁄4 cup brussels or broccoli sprouts, or\n1 tablespoon horseradish";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Arugula, bok choy, broccoli, brussels sprouts, cabbage, cauliflower, collard greens, horseradish, kale (black, green, and red), mustard greens, radish, turnip greens, and watercress"];
		
	} else if ([identifier compare:K_IDENTIFIER_GREENS] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_greens"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Greens";
		foodType.recommendedServingCount = 2.0;
		foodType.servingExample = @"1 cup raw, or\n1⁄2 cup cooked";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Arugula, beet greens, collard greens, kale (black, green, and red), mesclun mix (assorted young salad greens), mustard greens, sorrel, spinach, swiss chard, and turnip greens"];
		
	} else if ([identifier compare:K_IDENTIFIER_OTHER_VEG] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_other_veg"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Other Vegetable";
		foodType.recommendedServingCount = 2.0;
		foodType.servingExample = @"1 cup raw leafy vegetables, or\n1⁄2 cup raw or cooked nonleafy vegetables, or\n1⁄2 cup vegetable juice, or\n1⁄4 cup dried mushrooms";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Artichokes, asparagus, beets, bell peppers, carrots, corn, garlic, mushrooms (button, oyster, portobello, and shiitake), okra, onions, purple potatoes, pumpkin, sea vegetables (arame, dulse, and nori), snap peas, squash (delicata, summer, and spaghetti squash varieties), sweet potatoes/yams, tomatoes, and zucchini"];
		
	} else if ([identifier compare:K_IDENTIFIER_FLAX] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_flax"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Flaxseeds";
		foodType.recommendedServingCount = 1.0;
		foodType.servingExample = @"1 tablespoon ground";
		
	} else if ([identifier compare:K_IDENTIFIER_NUTS] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_nuts"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Nuts";
		foodType.recommendedServingCount = 1.0;
		foodType.servingExample = @"1⁄4 cup nuts or seeds, or\n2 tablespoons nut or seed butter";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Almonds, brazil nuts, cashews, chia seeds, hazelnuts/filberts, hemp seeds, macadamia nuts, pecans, pistachios, pumpkin seeds, sesame seeds, sunflower seeds, and walnuts"];
		
	} else if ([identifier compare:K_IDENTIFIER_SPICES] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_spices"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Spices";
		foodType.recommendedServingCount = 1.0;
		foodType.customRecommendation = @"1⁄4 teaspoon of turmeric, along with any other (salt-free) herbs and spices you enjoy";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Allspice, barberries, basil, bay leaves, cardamom, chili powder, cilantro, cinnamon, cloves, coriander, cumin, curry powder, dill, fenugreek, garlic, ginger, horseradish, lemongrass, marjoram, mustard powder, nutmeg, oregano, smoked paprika, parsley, pepper, peppermint, rosemary, saffron, sage, thyme, turmeric, and vanilla"];
		
	} else if ([identifier compare:K_IDENTIFIER_WHOLE_GRAINS] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_whole_grains"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Whole Grains";
		foodType.recommendedServingCount = 3.0;
		foodType.servingExample = @"1⁄2 cup hot cereal or cooked grains, pasta, or corn kernels, or\n1 cup cold cereal, or\n1 tortilla or slice of bread, or\n1⁄2 a bagel or english muffin, or\n3 cups popped popcorn";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Barley, brown rice, buckwheat, millet, oats, popcorn, quinoa, rye, teff, whole-wheat pasta, and wild rice"];
		
	} else if ([identifier compare:K_IDENTIFIER_BEVERAGES] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_beverages"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Beverages";
		foodType.recommendedServingCount = 5.0;
		foodType.servingExample = @"One glass (12 ounces)";
		[foodType.exampleTitles addObject:@"Some of my favorites:"];
		[foodType.exampleBodies addObject:@"Black tea, chai tea, vanilla chamomile tea, coffee, earl grey tea, green tea, hibiscus tea, hot chocolate, jasmine tea, lemon balm tea, matcha tea, almond blossom oolong tea, peppermint tea, rooibos tea, water, and white tea"];
		
	} else if ([identifier compare:K_IDENTIFIER_EXERCISES] == NSOrderedSame) {
		foodType.iconImageName = [UIImage imageNamed:@"ic_exercise"];
		foodType.overviewImageName = @"bkg_test";
		foodType.name = @"Exercise";
		foodType.recommendedServingCount = 1.0;
		foodType.servingExample = @"90 minutes of moderate-intensity activity, or\n40 minutes of vigorous activity";
		[foodType.exampleTitles addObject:@"Examples of moderate-intensity activities:"];
		[foodType.exampleBodies addObject:@"Bicycling, canoeing, dancing, dodgeball, downhill skiing, fencing, hiking, housework, ice skating, in-line skating, juggling, jumping on a trampoline, paddle boating, playing Frisbee, roller-skating, shooting baskets, shoveling light snow, skateboarding, snorkeling, surfing, swimming recreationally, tennis (doubles), treading water, walking briskly (4 MPH), water aerobics, water skiing, yard work, and yoga"];
		[foodType.exampleTitles addObject:@"Examples of vigorous activities:"];
		[foodType.exampleBodies addObject:@"Backpacking, basketball, bicycling uphill, circuit weight training, cross-country skiing, football, hockey, jogging, jumping jacks, jumping rope, lacrosse, push-ups and pull-ups, racquetball, rock climbing, rugby, running, scuba diving, tennis (singles), soccer, speed skating, squash, step aerobics, swimming laps, walking briskly uphill, and water jogging"];
		
	}
	
	return foodType;
}

@end
