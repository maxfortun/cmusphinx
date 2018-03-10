package tts;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;

import org.apache.commons.lang3.StringUtils;

import edu.cmu.sphinx.api.Configuration;
import edu.cmu.sphinx.api.LiveSpeechRecognizer;
import edu.cmu.sphinx.api.SpeechResult;
import edu.cmu.sphinx.result.WordResult;

import edu.cmu.sphinx.decoder.adaptation.Stats;
import edu.cmu.sphinx.decoder.adaptation.Transform;
import edu.cmu.sphinx.speakerid.Segment;
import edu.cmu.sphinx.speakerid.SpeakerCluster;
import edu.cmu.sphinx.speakerid.SpeakerIdentification;

import edu.cmu.sphinx.util.TimeFrame;

public class Live {	   

	public static void main(String[] args) throws Exception {
		Configuration configuration = new Configuration();
		configuration.setAcousticModelPath("resource:/edu/cmu/sphinx/models/en-us/en-us");
		configuration.setDictionaryPath("resource:/edu/cmu/sphinx/models/en-us/cmudict-en-us.dict");
		configuration.setLanguageModelPath("resource:/edu/cmu/sphinx/models/en-us/en-us.lm.bin");

		parseCommandLineArgs(args, configuration);

		SpeakerIdentification speakerIdentification = new SpeakerIdentification();

		LiveSpeechRecognizer recognizer = new LiveSpeechRecognizer(configuration);
		Stats stats = recognizer.createStats(1);


		SpeechResult result;
		TimeFrame t;

		recognizer.startRecognition(true);

		while ((result = recognizer.getResult()) != null) {

			stats.collect(result);

			System.out.format("Hypothesis: %s\n", result.getHypothesis());

			System.out.println("List of recognized words and their times:");
			for (WordResult r : result.getWords()) {
				System.out.println(r);
			}

			System.out.println("Best 3 hypothesis:");
			for (String s : result.getNbest(3)) {
                System.out.println(s);
			}

		}


		recognizer.stopRecognition();
	}

	private static void parseCommandLineArgs(String[] args, Configuration configuration) {
		try {
			parseCommandLineArgsImpl(args, configuration);
		} catch(Exception e) {
			System.err.println("Failed to parse command line arguments: "+StringUtils.join(args, " "));
			e.printStackTrace();
			System.exit(1);
		}
	}

	private static void parseCommandLineArgsImpl(String[] args, Configuration configuration) throws Exception {
		Options options = new Options();
		options.addOption(
			Option.builder("a").hasArg().desc("Acoustic model path. Default: "+configuration.getAcousticModelPath()).build()
		);

		options.addOption(
			Option.builder("d").hasArg().desc("Dictionary path. Default: "+configuration.getDictionaryPath()).build()
		);

		options.addOption(
			Option.builder("h").desc("This help.").build()
		);

		options.addOption(
			Option.builder("l").hasArg().desc("Language model path. Default: "+configuration.getLanguageModelPath()).build()
		);

		CommandLineParser parser = new DefaultParser();
		CommandLine cmd = parser.parse( options, args);

		if(cmd.hasOption("h")) {
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp(Live.class.getName(), "Live text to speech", options, "Use at your own peril", true);
			System.exit(0);
		}

		if(cmd.hasOption("a")) {
			configuration.setAcousticModelPath(cmd.getOptionValue("a"));
		}

		if(cmd.hasOption("d")) {
			configuration.setDictionaryPath(cmd.getOptionValue("d"));
		}

		if(cmd.hasOption("l")) {
			configuration.setLanguageModelPath(cmd.getOptionValue("l"));
		}
	}
}
