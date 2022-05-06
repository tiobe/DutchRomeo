// Copyright 2022, TIOBE Software B.V.
package com.tiobe.julia;

import com.google.gson.Gson;
import com.tiobe.antlr.JuliaLexer;
import com.tiobe.antlr.JuliaParser;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.stream.Collectors;

public class App {
    public static List<Rule> getRules(final List<String> ruleNames, final List<Violation> violations) {
        return ruleNames.stream()
                .map(App::getRuleByName)
                .map(x -> instantiateRule(x, violations))
                .collect(Collectors.toUnmodifiableList());
    }

    public static Class<Rule> getRuleByName(final String ruleName) {
        try {
            return (Class<Rule>) Class.forName(App.class.getPackageName() + "." + ruleName);
        } catch (final ClassNotFoundException e) {
            System.out.println("Rule '" + ruleName + "' doesn't exist, please choose another rule ID");
            System.exit(1);
            return null;
        }
    }

    public static Rule instantiateRule(final Class<Rule> ruleClass, final List<Violation> violations) {
        try {
            return ruleClass.getDeclaredConstructor(List.class).newInstance(violations);
        } catch (final Exception e) {
            throw new RuntimeException(e);
        }

    }

    private static String getVersion() throws IOException {
        final Properties prop = new Properties();
        try (InputStream in = App.class.getClassLoader().getResourceAsStream("build.properties")) {
            prop.load(in);
            return (String) prop.get("version");
        }
    }

    public static void main(final String... args) throws IOException {
        final List<String> ruleNames = new ArrayList<>();
        boolean jsonOutput = false;
        final List<String> filenames = new ArrayList<>();

        if (args.length == 0) {
            System.out.println("No argument provided, use 'DutchRomeo (--version | { --rule<digits> }* <inputfile>.jl)'");
            System.exit(1);
        }
        for (String arg : args) {
            if (arg.startsWith("--rule")) {
                ruleNames.add(String.format("Rule%s", (arg.substring(arg.lastIndexOf('e') + 1))));
            } else if (arg.toLowerCase().endsWith(".jl")) {
                if (new File(arg).exists()) {
                    filenames.add(arg);
                } else {
                    System.out.println("Input file '" + arg + "' doesn't exist");
                    System.exit(1);
                }
            } else if (arg.equals("--json")) {
                jsonOutput = true;
            } else if (arg.equals("--version")) {
                final String version = getVersion();
                System.out.println("DutchRomeo version " + version + ", Copyright 2022, TIOBE Software B.V.");
                System.exit(0);
            } else {
                System.out.println("Unknown option '" + arg + "' encountered, please run without arguments for help");
                System.exit(1);
            }
        }

        if (filenames.isEmpty()) {
            System.out.println("No input file name specified");
            System.exit(1);
        }

        checkViolations(filenames, ruleNames, jsonOutput);

        System.exit(0);
    }

    private static void checkViolations(final List<String> filenames, final List<String> ruleNames, final boolean jsonOutput) throws IOException {
        final Map<String, List<Violation>> violationsPerFile = getViolationsPerFile(filenames, ruleNames);

        if (jsonOutput) {
            final Gson gson = new Gson();
            final String jsonString = gson.toJson(Map.of("violations", violationsPerFile));
            System.out.println(jsonString);
        } else {
            final List<Violation> violations = violationsPerFile.values().stream()
                    .flatMap(List::stream)
                    .collect(Collectors.toUnmodifiableList());
            if (violations.isEmpty()) {
                System.out.println("No violations found");
            }
            for (Violation violation : violations) {
                violation.printToStdout();
            }
        }
    }

    public static Map<String, List<Violation>> getViolationsPerFile(final List<String> filenames, final List<String> ruleNames) throws IOException {
        final Map<String, List<Violation>> violationsPerFile = new HashMap<>();
        for (String filename : filenames) {
            violationsPerFile.put(filename, getViolations(filename, ruleNames));
        }
        return violationsPerFile;
    }

    public static List<Violation> getViolations(final String filename, final List<String> ruleNames) throws IOException {
        final CharStream charStream = CharStreams.fromFileName(filename);
        final JuliaLexer lexer = new JuliaLexer(charStream);
        final CommonTokenStream tokens = new CommonTokenStream(lexer);
        final JuliaParser parser = new JuliaParser(tokens);
        final ParseTree tree = parser.main();
        final ParseTreeWalker walker = new ParseTreeWalker();
        final List<Violation> violations = new ArrayList<>(); // TODO: rewrite so that violations are printed while running (stream)
        final List<Rule> rules = getRules(ruleNames, violations);

        walker.walk(new JuliaListener(Path.of(filename).toRealPath(), tokens, rules), tree);
        return violations;
    }
}
