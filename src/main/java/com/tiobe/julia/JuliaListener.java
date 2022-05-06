package com.tiobe.julia;

import com.tiobe.antlr.JuliaBaseListener;
import com.tiobe.antlr.JuliaParser;
import org.antlr.v4.runtime.BufferedTokenStream;

import java.nio.file.Path;
import java.util.List;

public class JuliaListener extends JuliaBaseListener {
    private final Path filename;
    private final List<Rule> rules;
    private final BufferedTokenStream tokens;

    public JuliaListener(final Path filename, final BufferedTokenStream tokens, final List<Rule> rules) {
        this.filename = filename;
        this.rules = rules;
        for (final Rule rule : this.rules) {
            rule.check(filename, tokens);
        }
        this.tokens = tokens;
    }

    @Override
    public void enterMain(final JuliaParser.MainContext ctx) {
        for (final Rule rule : rules) {
            rule.check(filename, ctx, tokens);
        }
    }

    @Override
    public void enterFunctionDefinition1(final JuliaParser.FunctionDefinition1Context ctx) {
        for (final Rule rule : rules) {
            rule.check(filename, ctx, tokens);
        }
    }
}

