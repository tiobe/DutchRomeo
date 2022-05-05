package com.tiobe.julia;

import com.tiobe.antlr.JuliaBaseListener;
import com.tiobe.antlr.JuliaParser;
import org.antlr.v4.runtime.BufferedTokenStream;

import java.util.List;

public class JuliaListener extends JuliaBaseListener {
    private final List<Rule> rules;
    private BufferedTokenStream tokens;

    public JuliaListener(final BufferedTokenStream tokens, final List<Rule> rules) {
        this.rules = rules;
        for (final Rule rule : this.rules) {
            rule.check(tokens);
        }
        this.tokens = tokens;
    }

    @Override
    public void enterMain(final JuliaParser.MainContext ctx) {
        for (final Rule rule : rules) {
            rule.check(ctx, tokens);
        }
    }

    @Override
    public void enterFunctionDefinition1(final JuliaParser.FunctionDefinition1Context ctx) {
        for (final Rule rule : rules) {
            rule.check(ctx, tokens);
        }
    }
}

