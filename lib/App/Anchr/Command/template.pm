package App::Anchr::Command::template;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

sub abstract {
    return 'create executing bash files';
}

sub opt_spec {
    return (
        [ "basename=s",   "the basename of this genome, default is the working directory", ],
        [ "queue=s",      "QUEUE_NAME", { default => "mpi" }, ],
        [ "genome=i",     "your best guess of the haploid genome size", ],
        [ "is_euk",       "eukaryotes or not", ],
        [ "se",           "single end mode for Illumina", ],
        [ "parallel|p=i", "number of threads", { default => 16 }, ],
        [ "xmx=s",        "set Java memory usage", ],
        [],
        [ 'fastqc',     'run FastQC', ],
        [ 'kmergenie',  'run KmerGenie', ],
        [ 'insertsize', 'calc the insert sizes', ],
        [ 'sgapreqc',   'run sga preqc', ],
        [ 'sgastats',   'run sga stats', ],
        [ "reads=i",    "how many reads to estimate insert size", { default => 1000000 }, ],
        [],
        [ "trim2=s",   "opts for trimming Illumina reads", { default => "--dedupe" }, ],
        [ "sample2=i", "total sampling coverage of Illumina reads", ],
        [ "qual2=s",   "quality threshold",                         { default => "25 30" }, ],
        [ "len2=s",    "filter reads less or equal to this length", { default => "60" }, ],
        [ "filter=s",  "adapter, artifact",                         { default => "adapter" }, ],
        [],
        [ 'noquorum',    'skip quorum', ],
        [ 'mergereads',  'also run the mergereads approach', ],
        [ "prefilter=i", "prefilter=N (1 or 2) for tadpole and bbmerge", ],
        [ 'ecphase=s',   'Error-correct phases', { default => "1,2,3", }, ],
        [],
        [ "cov2=s",      "down sampling coverage of Illumina reads", { default => "40 80" }, ],
        [ 'tadpole',     'use tadpole to create k-unitigs', ],
        [ 'megahit',     'feed megahit with sampled mergereads', ],
        [ 'spades',      'feed spades with sampled mergereads', ],
        [ "splitp=i",    "parts of splitting", { default => 50 }, ],
        [ "statp=i",     "parts of stats",     { default => 50 }, ],
        [ 'redoanchors', 'redo anchors when merging anchors', ],
        [],
        [ "cov3=s",  "down sampling coverage of PacBio/NanoPore reads", ],
        [ "qual3=s", "raw and/or trim", { default => "trim" } ],
        [],
        [ 'fillanchor', 'fill gaps among anchors with 2GS contigs', ],
        [ "mergemax=i", "max length of merged overlaps", { default => 30 }, ],
        [ "fillmax=i",  "max length of gaps",            { default => 2000 }, ],
        [],
        [ 'trinity',  'de novo rna-seq', ],
        [ "rnamin=i", "minimum assembled contig length", { default => 200 }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr template [options] <working directory>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFastq files can be gzipped\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( @{$args} != 1 ) {
        my $message = "This command need one directory.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_dir ) {
            $self->usage_error("The input directory [$_] doesn't exist.");
        }
    }

    $args->[0] = Path::Tiny::path( $args->[0] )->absolute;

    if ( !$opt->{basename} ) {
        $opt->{basename} = Path::Tiny::path( $args->[0] )->basename();
    }

    $opt->{parallel2} = int( $opt->{parallel} / 2 );
    $opt->{parallel2} = 2 if $opt->{parallel2} < 2;

}

sub execute {
    my ( $self, $opt, $args ) = @_;

    # fastqc
    $self->gen_fastqc( $opt, $args );

    # kmergenie
    $self->gen_kmergenie( $opt, $args );

    # insertSize
    $self->gen_insertSize( $opt, $args );

    # sgaPreQC
    $self->gen_sgaPreQC( $opt, $args );

    # mergereads
    $self->gen_mergereads( $opt, $args );

    # trim2
    $self->gen_trim( $opt, $args );

    # trimlong
    $self->gen_trimlong( $opt, $args );

    # statReads
    $self->gen_statReads( $opt, $args );

    # quorum
    $self->gen_quorum( $opt, $args );

    # downSampling
    $self->gen_downSampling( $opt, $args );

    # kunitigs
    $self->gen_kunitigs( $opt, $args );

    # anchors
    $self->gen_anchors( $opt, $args );

    # statAnchors
    $self->gen_statAnchors( $opt, $args );

    # 6_downSampling
    $self->gen_6_downSampling( $opt, $args );

    # 6_kunitigs
    $self->gen_6_kunitigs( $opt, $args );

    # 6_anchors
    $self->gen_6_anchors( $opt, $args );

    # 6_statAnchors
    $self->gen_statMRAnchors( $opt, $args );

    # mergeAnchors
    $self->gen_mergeAnchors( $opt, $args );

    # statMergeAnchors
    $self->gen_statMergeAnchors( $opt, $args );

    # canu
    $self->gen_canu( $opt, $args );

    # statCanu
    $self->gen_statCanu( $opt, $args );

    # anchorLong
    $self->gen_anchorLong( $opt, $args );

    # anchorFill
    $self->gen_anchorFill( $opt, $args );

    # spades
    $self->gen_spades( $opt, $args );

    # megahit
    $self->gen_megahit( $opt, $args );

    # platanus
    $self->gen_platanus( $opt, $args );

    # statOtherAnchors
    $self->gen_statOtherAnchors( $opt, $args );

    # trinity
    $self->gen_trinity( $opt, $args );

    # quast
    $self->gen_quast( $opt, $args );

    # statFinal
    $self->gen_statFinal( $opt, $args );

    # cleanup
    $self->gen_cleanup( $opt, $args );

    # realClean
    $self->gen_realClean( $opt, $args );

    # master
    $self->gen_master( $opt, $args );

    # bsub
    $self->gen_bsub( $opt, $args );

}

sub gen_fastqc {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{fastqc};

    $sh_name = "2_fastqc.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

for PREFIX in R S T; do
    if [ ! -e ../${PREFIX}1.fq.gz ]; then
        continue;
    fi

    if [ ! -e ${PREFIX}1_fastqc.html ]; then
        fastqc -t [% opt.parallel %] \
            ../${PREFIX}1.fq.gz [% IF not opt.se %]../${PREFIX}2.fq.gz[% END %] \
            -o .
    fi
done

exit;

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_kmergenie {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{kmergenie};

    $sh_name = "2_kmergenie.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

for PREFIX in R S T; do
    if [ ! -e ../${PREFIX}1.fq.gz ]; then
        continue;
    fi

    if [ ! -e ${PREFIX}1.dat.pdf ]; then
        parallel --no-run-if-empty --linebuffer -k -j 2 "
            kmergenie -l 21 -k 121 -s 10 -t [% opt.parallel2 %] --one-pass ../{}.fq.gz -o {}
            " ::: ${PREFIX}1 [% IF not opt.se %]${PREFIX}2[% END %]
    fi
done

exit;

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_insertSize {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return if $opt->{se};
    return unless $opt->{insertsize};

    $sh_name = "2_insertSize.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

mkdir -p 2_illumina/insertSize
cd 2_illumina/insertSize

for PREFIX in R S T; do
    if [ ! -e ../${PREFIX}1.fq.gz ]; then
        continue;
    fi

    if [ -e ${PREFIX}.ihist.tadpole.txt ]; then
        continue;
    fi

    tadpole.sh \
        in=../${PREFIX}1.fq.gz \
        in2=../${PREFIX}2.fq.gz \
        out=${PREFIX}.tadpole.contig.fasta \
        threads=[% opt.parallel %] \
        overwrite [% IF opt.prefilter %]prefilter=[% opt.prefilter %][% END %]

    bbmap.sh \
        in=../${PREFIX}1.fq.gz \
        in2=../${PREFIX}2.fq.gz \
        out=${PREFIX}.tadpole.sam.gz \
        ref=${PREFIX}.tadpole.contig.fasta \
        threads=[% opt.parallel %] \
        pairedonly \
        reads=[% opt.reads %] \
        nodisk overwrite

    reformat.sh \
        in=${PREFIX}.tadpole.sam.gz \
        ihist=${PREFIX}.ihist.tadpole.txt \
        overwrite

    picard SortSam \
        -I ${PREFIX}.tadpole.sam.gz \
        -O ${PREFIX}.tadpole.sort.bam \
        -SORT_ORDER coordinate \
        -VALIDATION_STRINGENCY LENIENT

    picard CollectInsertSizeMetrics \
        -I ${PREFIX}.tadpole.sort.bam \
        -O ${PREFIX}.insert_size.tadpole.txt \
        -HISTOGRAM_FILE ${PREFIX}.insert_size.tadpole.pdf

    if [ -e ../../1_genome/genome.fa ]; then
        bbmap.sh \
            in=../${PREFIX}1.fq.gz \
            in2=../${PREFIX}2.fq.gz \
            out=${PREFIX}.genome.sam.gz \
            ref=../../1_genome/genome.fa \
            threads=[% opt.parallel %] \
            maxindel=0 strictmaxindel \
            reads=[% opt.reads %] \
            nodisk overwrite

        reformat.sh \
            in=${PREFIX}.genome.sam.gz \
            ihist=${PREFIX}.ihist.genome.txt \
            overwrite

        picard SortSam \
            -I ${PREFIX}.genome.sam.gz \
            -O ${PREFIX}.genome.sort.bam \
            -SORT_ORDER coordinate \
            -VALIDATION_STRINGENCY LENIENT

        picard CollectInsertSizeMetrics \
            -I ${PREFIX}.genome.sort.bam \
            -O ${PREFIX}.insert_size.genome.txt \
            -HISTOGRAM_FILE ${PREFIX}.insert_size.genome.pdf
    fi

    find . -name "${PREFIX}.*.sam.gz" -or -name "${PREFIX}.*.sort.bam" |
        parallel --no-run-if-empty -j 1 rm
done

echo -e "Table: statInsertSize\n" > statInsertSize.md
printf "| %s | %s | %s | %s | %s |\n" \
    "Group" "Mean" "Median" "STDev" "PercentOfPairs/PairOrientation" \
    >> statInsertSize.md
printf "|:--|--:|--:|--:|--:|\n" >> statInsertSize.md

# bbtools reformat.sh
#Mean	339.868
#Median	312
#Mode	251
#STDev	134.676
#PercentOfPairs	36.247
for PREFIX in R S T; do
    for G in genome tadpole; do
        if [ ! -e ${PREFIX}.ihist.${G}.txt ]; then
            continue;
        fi

        printf "| %s " "${PREFIX}.${G}.bbtools" >> statInsertSize.md
        cat ${PREFIX}.ihist.${G}.txt \
            | perl -nla -e '
                BEGIN { our $stat = { }; };

                m{\#(Mean|Median|STDev|PercentOfPairs)} or next;
                $stat->{$1} = $F[1];

                END {
                    printf qq{| %.1f | %s | %.1f | %.2f%% |\n},
                        $stat->{Mean},
                        $stat->{Median},
                        $stat->{STDev},
                        $stat->{PercentOfPairs};
                }
                ' \
            >> statInsertSize.md
    done
done

# picard CollectInsertSizeMetrics
#MEDIAN_INSERT_SIZE	MODE_INSERT_SIZE	MEDIAN_ABSOLUTE_DEVIATION	MIN_INSERT_SIZE	MAX_INSERT_SIZE	MEAN_INSERT_SIZE	STANDARD_DEVIATION	READ_PAIRS	PAIR_ORIENTATION	WIDTH_OF_10_PERCENT	WIDTH_OF_20_PERCENT	WIDTH_OF_30_PERCENT	WIDTH_OF_40_PERCENT	WIDTH_OF_50_PERCENT	WIDTH_OF_60_PERCENT	WIDTH_OF_70_PERCENT	WIDTH_OF_80_PERCENT	WIDTH_OF_90_PERCENT	WIDTH_OF_95_PERCENT	WIDTH_OF_99_PERCENT	SAMPLE	LIBRARY	READ_GROUP
#296	287	14	92	501	294.892521	21.587526	1611331	FR	7	11	17	23	29	35	41	49	63	81	145
for PREFIX in R S T; do
    for G in genome tadpole; do
        if [ ! -e ${PREFIX}.insert_size.${G}.txt ]; then
            continue;
        fi

        cat ${PREFIX}.insert_size.${G}.txt \
            | GROUP="${PREFIX}.${G}" perl -nla -F"\t" -e '
                next if @F < 9;
                next unless /^\d/;
                printf qq{| %s | %.1f | %s | %.1f | %s |\n},
                    qq{$ENV{GROUP}.picard},
                    $F[5],
                    $F[0],
                    $F[6],
                    $F[8];
                ' \
            >> statInsertSize.md
    done
done

cat statInsertSize.md

mv statInsertSize.md ../../

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_sgaPreQC {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{sgapreqc};

    $sh_name = "2_sgaPreQC.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

mkdir -p 2_illumina/sgaPreQC
cd 2_illumina/sgaPreQC

for PREFIX in R S T; do
    if [ ! -e ../${PREFIX}1.fq.gz ]; then
        continue;
    fi

    if [ -e ${PREFIX}.preqc.pdf ]; then
        continue;
    fi

    sga preprocess \
[% IF opt.se -%]
        ../${PREFIX}1.fq.gz \
[% ELSE -%]
        ../${PREFIX}1.fq.gz ../${PREFIX}2.fq.gz \
        --pe-mode 1 \
[% END -%]
        -o ${PREFIX}.pp.fq

    sga index -a ropebwt -t [% opt.parallel %] ${PREFIX}.pp.fq

    sga preqc -t [% opt.parallel %] ${PREFIX}.pp.fq > ${PREFIX}.preqc_output

    sga-preqc-report.py ${PREFIX}.preqc_output -o ${PREFIX}.preqc

[% IF opt.sgastats -%]
    sga stats -t [% opt.parallel %] -n [% opt.reads %] ${PREFIX}.pp.fq > ${PREFIX}.stats.txt
[% END -%]

    find . -type f -name "${PREFIX}.pp.*" |
        parallel --no-run-if-empty -j 1 rm

done

[% IF opt.sgastats -%]
echo -e "Table: statSgaStats\n" > statSgaStats.md
printf "| %s | %s | %s | %s |\n" \
    "Library" "incorrectBases" "perfectReads" "overlapDepth" \
    >> statSgaStats.md
printf "|:--|--:|--:|--:|\n" >> statSgaStats.md

# sga stats
#*** Stats:
#380308 out of 149120670 bases are potentially incorrect (0.002550)
#797208 reads out of 1000000 are perfect (0.797208)
#Mean overlap depth: 356.41
for PREFIX in R S T; do
    if [ ! -e ${PREFIX}.stats.txt ]; then
        continue;
    fi

    printf "| %s " "${PREFIX}" >> statSgaStats.md
    cat ${PREFIX}.stats.txt |
        perl -nl -e '
            BEGIN { our $stat = { }; };

            m{potentially incorrect \(([\d\.]+)\)} and $stat->{incorrectBases} = $1;
            m{perfect \(([\d\.]+)\)} and $stat->{perfectReads} = $1;
            m{overlap depth: ([\d\.]+)} and $stat->{overlapDepth} = $1;

            END {
                printf qq{| %.2f%% | %.2f%% | %s |\n},
                    $stat->{incorrectBases} * 100,
                    $stat->{perfectReads} * 100,
                    $stat->{overlapDepth};
            }
            ' \
        >> statSgaStats.md
done
[% END -%]

cat statSgaStats.md

mv statSgaStats.md ../../

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_trim {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "2_trim.sh";
    print "Create $sh_name\n";

    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

#----------------------------#
# run
#----------------------------#
mkdir -p 2_illumina/trim
cd 2_illumina/trim

for PREFIX in R S T; do
    if [ ! -e ../${PREFIX}1.fq.gz ]; then
        continue;
    fi

    if [ -e ${PREFIX}1.fq.gz ]; then
        log_debug "2_illumina/trim/${PREFIX}1.fq.gz presents"
        continue;
    fi

    anchr trim \
        [% opt.trim2 %] \
        --qual "[% opt.qual2 %]" \
        --len "[% opt.len2 %]" \
    [% IF opt.filter -%]
        --filter [% opt.filter %] \
    [% END -%]
    [% IF opt.sample2 -%]
    [% IF opt.genome -%]
        --sample $(( [% opt.genome %] * [% opt.sample2 %] )) \
    [% END -%]
    [% END -%]
        --parallel [% opt.parallel %] [% IF opt.xmx %]--xmx [% opt.xmx %][% END %] \
        ../${PREFIX}1.fq.gz [% IF not opt.se %]../${PREFIX}2.fq.gz[% END %] \
        --prefix ${PREFIX} \
        -o trim.sh
    bash trim.sh

    log_info "stats of all .fq.gz files"

    if [ ! -e statTrimReads.md ]; then
        echo -e "Table: statTrimReads\n" > statTrimReads.md
        printf "| %s | %s | %s | %s |\n" \
            "Name" "N50" "Sum" "#" \
            >> statTrimReads.md
        printf "|:--|--:|--:|--:|\n" >> statTrimReads.md
    fi

    for NAME in clumpify filteredbytile highpass sample trim filter ${PREFIX}1 ${PREFIX}2 ${PREFIX}s; do
        if [ ! -e ${NAME}.fq.gz ]; then
            continue;
        fi

        printf "| %s | %s | %s | %s |\n" \
            $(echo ${NAME}; stat_format ${NAME}.fq.gz;) >> statTrimReads.md
    done

    log_info "clear unneeded .fq.gz files"
    for NAME in temp clumpify filteredbytile highpass sample trim filter; do
        if [ -e ${NAME}.fq.gz ]; then
            rm ${NAME}.fq.gz
        fi
    done
done

for PREFIX in R S T; do
    if [ ! -s statTrimReads.md ]; then
        continue;
    fi

    echo >> statTrimReads.md

    if [ -e ${PREFIX}.trim.stats.txt ]; then
        echo >> statTrimReads.md
        echo '```text' >> statTrimReads.md
        echo "#${PREFIX}.trim" >> statTrimReads.md
        cat ${PREFIX}.trim.stats.txt |
            perl -nla -F"\t" -e '
                /^#(Matched|Name)/ and print and next;
                /^#/ and next;
                $F[2] =~ m{([\d.]+)} and $1 > 0.1 and print;
            ' \
            >> statTrimReads.md
        echo '```' >> statTrimReads.md
    fi

    if [ -e ${PREFIX}.filter.stats.txt ]; then
        echo >> statTrimReads.md
        echo '```text' >> statTrimReads.md
        echo "#${PREFIX}.filter" >> statTrimReads.md
        cat ${PREFIX}.filter.stats.txt |
            perl -nla -F"\t" -e '
                /^#(Matched|Name)/ and print and next;
                /^#/ and next;
                $F[2] =~ m{([\d.]+)} and $1 > 0.01 and print;
            ' \
            >> statTrimReads.md
        echo '```' >> statTrimReads.md
    fi

    if [ -e ${PREFIX}.peaks.txt ]; then
        echo >> statTrimReads.md
        echo '```text' >> statTrimReads.md
        echo "#${PREFIX}.peaks" >> statTrimReads.md
        cat ${PREFIX}.peaks.txt |
            grep "^#" \
            >> statTrimReads.md
        echo '```' >> statTrimReads.md
    fi
done

if [ -s statTrimReads.md ]; then
    cat statTrimReads.md
    mv statTrimReads.md ../../
fi

cd ${BASH_DIR}
cd 2_illumina

parallel --no-run-if-empty --linebuffer -k -j 2 "
    ln -fs ./trim/Q{1}L{2}/ ./Q{1}L{2}
    " ::: [% opt.qual2 %] ::: [% opt.len2 %]
ln -fs ./trim ./Q0L0

exit 0;

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_mergereads {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{mergereads};
    return if $opt->{se};

    $sh_name = "2_mergereads.sh";
    print "Create $sh_name\n";

    $tt->process(
        '2_mergereads.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_trimlong {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{cov3};

    $sh_name = "3_trimlong.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

for X in [% opt.cov3 %]; do
    printf "==> Coverage: %s\n" ${X}

    if [ -e 3_long/L.X${X}.raw.fasta.gz ]; then
        echo "  L.X${X}.raw.fasta.gz presents";
        continue;
    fi

    # shortcut if cov3 == all
    if [[ ${X} == "all" ]]; then
        pushd 3_long > /dev/null

        ln -s L.fasta.gz L.X${X}.raw.fasta.gz

        popd > /dev/null
        continue;
    fi

    faops split-about -m 1 -l 0 \
        3_long/L.fasta.gz \
        $(( [% opt.genome %] * ${X} )) \
        3_long

    cat 3_long/000.fa | pigz > "3_long/L.X${X}.raw.fasta.gz"
    rm 3_long/000.fa
done

for X in  [% opt.cov3 %]; do
    printf "==> Coverage: %s\n" ${X}

    if [ -e 3_long/L.X${X}.trim.fasta.gz ]; then
        echo "  L.X${X}.trim.fasta.gz presents";
        continue;
    fi

    anchr trimlong --parallel [% opt.parallel2 %] -v \
        "3_long/L.X${X}.raw.fasta.gz" \
        -o stdout |
        pigz > "3_long/L.X${X}.trim.fasta.gz"
done

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_statReads {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statReads.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statReads.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_quorum {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "2_quorum.sh";
    print "Create $sh_name\n";

    if ( $opt->{noquorum} ) {
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

for Q in 0 [% opt.qual2 %]; do
    for L in 0 [% opt.len2 %]; do
        cd ${BASH_DIR}

        if [ ! -d 2_illumina/Q${Q}L${L} ]; then
            continue;
        fi

        if [ -e 2_illumina/Q${Q}L${L}/pe.cor.fa.gz ]; then
            log_debug "2_illumina/Q${Q}L${L}/pe.cor.fa.gz presents"
            continue;
        fi

        cd 2_illumina/Q${Q}L${L}

        for PREFIX in R S T; do
            if [ ! -e ${PREFIX}1.fq.gz ]; then
                continue;
            fi

            if [ -e ${PREFIX}.cor.fa.gz ]; then
                echo >&2 "    ${PREFIX}.cor.fa.gz exists"
                continue;
            fi

            log_info "Qual-Len: Q${Q}L${L}.${PREFIX}"
            log_info "    faops interleave"

            # Create .cor.fa.gz
            faops interleave \
                -p pe \
                ${PREFIX}1.fq.gz \
[% IF not opt.se -%]
                ${PREFIX}2.fq.gz \
[% END -%]
                > ${PREFIX}.interleave.fa

            if [ -e ${PREFIX}s.fq.gz ]; then
                faops interleave \
                    -p se \
                    ${PREFIX}s.fq.gz \
                    >> ${PREFIX}.interleave.fa
            fi

            # Shuffle interleaved reads.
            log_info Shuffle interleaved reads.
            cat ${PREFIX}.interleave.fa |
                awk '{
                    OFS="\t"; \
                    getline seq; \
                    getline name2; \
                    getline seq2; \
                    print $0,seq,name2,seq2}' |
                shuf |
                awk '{OFS="\n"; print $1,$2,$3,$4}' \
                > ${PREFIX}.cor.fa
            rm ${PREFIX}.interleave.fa
            pigz -p [% opt.parallel %] ${PREFIX}.cor.fa

        done

        log_info "Combine Q${Q}L${L} .cor.fa.gz files"
        if [ -e S1.fq.gz ]; then
            gzip -d -c [RST].cor.fa.gz |
                awk '{
                    OFS="\t"; \
                    getline seq; \
                    getline name2; \
                    getline seq2; \
                    print $0,seq,name2,seq2}' |
                shuf |
                awk '{OFS="\n"; print $1,$2,$3,$4}' \
                > pe.cor.fa
            pigz -p [% opt.parallel %] pe.cor.fa
            rm [RST].cor.fa.gz
        else
            mv R.cor.fa.gz pe.cor.fa.gz
        fi
    done
done

EOF
    }
    else {
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

for Q in 0 [% opt.qual2 %]; do
    for L in 0 [% opt.len2 %]; do
        cd ${BASH_DIR}

        if [ ! -d 2_illumina/Q${Q}L${L} ]; then
            continue;
        fi

        if [ -e 2_illumina/Q${Q}L${L}/pe.cor.fa.gz ]; then
            log_debug "2_illumina/Q${Q}L${L}/pe.cor.fa.gz presents"
            continue;
        fi

        START_TIME=$(date +%s)

        cd 2_illumina/Q${Q}L${L}

        for PREFIX in R S T; do
            if [ ! -e ${PREFIX}1.fq.gz ]; then
                continue;
            fi

            if [ -e ${PREFIX}.cor.fa.gz ]; then
                echo >&2 "    ${PREFIX}.cor.fa.gz exists"
                continue;
            fi

            log_info "Qual-Len: Q${Q}L${L}.${PREFIX}"

            anchr quorum \
                ${PREFIX}1.fq.gz \
[% IF not opt.se -%]
                ${PREFIX}2.fq.gz \
                $(
                    if [ -e ${PREFIX}s.fq.gz ]; then
                        echo ${PREFIX}s.fq.gz;
                    fi
                ) \
[% END -%]
                -p [% opt.parallel %] \
                --prefix ${PREFIX} \
                -o quorum.sh
            bash quorum.sh

            log_info "statQuorum.${PREFIX}"

            SUM_IN=$( cat environment.json | jq '.SUM_IN | tonumber' )
            SUM_OUT=$( cat environment.json | jq '.SUM_OUT | tonumber' )
            EST_G=$( cat environment.json | jq '.ESTIMATED_GENOME_SIZE | tonumber' )
            SECS=$( cat environment.json | jq '.RUNTIME | tonumber' )

            printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s |\n" \
                "Q${Q}L${L}.${PREFIX}" \
                $( perl -e "printf qq{%.1f}, ${SUM_IN} / [% opt.genome %];" ) \
                $( perl -e "printf qq{%.1f}, ${SUM_OUT} / [% opt.genome %];" ) \
                $( perl -e "printf qq{%.2f%%}, (1 - ${SUM_OUT} / ${SUM_IN}) * 100;" ) \
                $( cat environment.json | jq '.KMER' ) \
                $( perl -MNumber::Format -e "print Number::Format::format_bytes([% opt.genome %], base => 1000,);" ) \
                $( perl -MNumber::Format -e "print Number::Format::format_bytes(${EST_G}, base => 1000,);" ) \
                $( perl -e "printf qq{%.2f}, ${EST_G} / [% opt.genome %]" ) \
                $( printf "%d:%02d'%02d''\n" $((${SECS}/3600)) $((${SECS}%3600/60)) $((${SECS}%60)) ) \
                > statQuorum.${PREFIX}

        done

        log_info "Combine Q${Q}L${L} .cor.fa.gz files"
        if [ -e S1.fq.gz ]; then
            gzip -d -c [RST].cor.fa.gz |
                awk '{
                    OFS="\t"; \
                    getline seq; \
                    getline name2; \
                    getline seq2; \
                    print $0,seq,name2,seq2}' |
                shuf |
                awk '{OFS="\n"; print $1,$2,$3,$4}' \
                > pe.cor.fa
            pigz -p [% opt.parallel %] pe.cor.fa
            rm [RST].cor.fa.gz
        else
            mv R.cor.fa.gz pe.cor.fa.gz
        fi

        rm environment.json
        log_debug "Reads stats with faops"
        SUM_OUT=$( faops n50 -H -N 0 -S pe.cor.fa.gz )
        save SUM_OUT

        save START_TIME
        END_TIME=$(date +%s)
        save END_TIME
        RUNTIME=$((END_TIME-START_TIME))
        save RUNTIME

        # save genome size
        ESTIMATED_GENOME_SIZE=[% opt.genome %]
        save ESTIMATED_GENOME_SIZE

    done
done

cd ${BASH_DIR}/2_illumina

if [ -e Q0L0/statQuorum.R ]; then
    echo -e "Table: statQuorum\n" > statQuorum.md
    printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s |\n" \
        "Name" "CovIn" "CovOut" "Discard%" \
        "Kmer" "RealG" "EstG" "Est/Real" \
        "RunTime" \
        >> statQuorum.md
    printf "|:--|--:|--:|--:|--:|--:|--:|--:|--:|\n" \
        >> statQuorum.md

    for PREFIX in R S T; do
        for Q in 0 [% opt.qual2 %]; do
            for L in 0 [% opt.len2 %]; do
                if [ -e Q${Q}L${L}/statQuorum.${PREFIX} ]; then
                    cat Q${Q}L${L}/statQuorum.${PREFIX} >> statQuorum.md;
                fi
            done
        done
    done

    cat statQuorum.md
    mv statQuorum.md ../
fi

EOF
    }
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_downSampling {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "4_downSampling.sh";
    print "Create $sh_name\n";

    $tt->process(
        '4_downSampling.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_6_downSampling {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{mergereads};
    return if $opt->{se};

    $sh_name = "6_downSampling.sh";
    print "Create $sh_name\n";

    $tt->process(
        '6_downSampling.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_kunitigs {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "4_kunitigs.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 4_downSampling/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 4_kunitigs/Q{1}L{2}X{3}P{4}'
    if [ -e 4_kunitigs/Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 4_kunitigs/Q{1}L{2}X{3}P{4}
    cd 4_kunitigs/Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../../4_downSampling/Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../../4_downSampling/Q{1}L{2}X{3}P{4}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: 0 [% opt.qual2 %] ::: 0 [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( $opt->{tadpole} ) {
        $sh_name = "4_tadpole.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 4_downSampling/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 4_tadpole/Q{1}L{2}X{3}P{4}'
    if [ -e 4_tadpole/Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 4_tadpole/Q{1}L{2}X{3}P{4}
    cd 4_tadpole/Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../../4_downSampling/Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../../4_downSampling/Q{1}L{2}X{3}P{4}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        --tadpole \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: 0 [% opt.qual2 %] ::: 0 [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_6_kunitigs {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{mergereads};
    return if $opt->{se};

    $sh_name = "6_kunitigs.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 6_downSampling/MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 6_kunitigs/MRX{1}P{2}'
    if [ -e 6_kunitigs/MRX{1}P{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 6_kunitigs/MRX{1}P{2}
    cd 6_kunitigs/MRX{1}P{2}

    anchr kunitigs \
        ../../6_downSampling/MRX{1}P{2}/pe.cor.fa \
        ../../6_downSampling/MRX{1}P{2}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( $opt->{tadpole} ) {
        $sh_name = "6_tadpole.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 6_downSampling/MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 6_tadpole/MRX{1}P{2}'
    if [ -e 6_tadpole/MRX{1}P{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 6_tadpole/MRX{1}P{2}
    cd 6_tadpole/MRX{1}P{2}

    anchr kunitigs \
        ../../6_downSampling/MRX{1}P{2}/pe.cor.fa \
        ../../6_downSampling/MRX{1}P{2}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        --tadpole \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

    if ( $opt->{megahit} ) {
        $sh_name = "6_megahit.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 6_downSampling/MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 6_megahit/MRX{1}P{2}'
    if [ -e 6_megahit/MRX{1}P{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 6_megahit/MRX{1}P{2}
    cd 6_megahit/MRX{1}P{2}

    ln -s ../../6_downSampling/MRX{1}P{2}/pe.cor.fa pe.cor.fa
    cp ../../6_downSampling/MRX{1}P{2}/environment.json environment.json

    START_TIME=\$(date +%s)

    megahit \
        -t [% opt.parallel %] \
        --k-list 31,41,51,61,71,81 \
        --12 pe.cor.fa \
        --min-count 3 \
        -o megahit_out

    anchr contained \
        megahit_out/final.contigs.fa \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin k_unitigs.fasta

    END_TIME=\$(date +%s)
    RUNTIME=\$((END_TIME-START_TIME))

    TJQ=\$(jq \".RUNTIME = \"\${RUNTIME}\"\" < environment.json)
    [[ \$? == 0 ]] && echo \"\${TJQ}\" >| environment.json

    SUM_COR=\$( faops n50 -H -N 0 -S pe.cor.fa )

    TJQ=\$(jq \".SUM_COR = \"\${SUM_COR}\"\" < environment.json)
    [[ \$? == 0 ]] && echo \"\${TJQ}\" >| environment.json

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

    if ( $opt->{spades} ) {
        $sh_name = "6_spades.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 6_downSampling/MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 6_spades/MRX{1}P{2}'
    if [ -e 6_spades/MRX{1}P{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 6_spades/MRX{1}P{2}
    cd 6_spades/MRX{1}P{2}

    ln -s ../../6_downSampling/MRX{1}P{2}/pe.cor.fa pe.cor.fa
    cp ../../6_downSampling/MRX{1}P{2}/environment.json environment.json

    START_TIME=\$(date +%s)

    # Separates paired reads
    mkdir -p re-pair
    faops filter -l 0 -a 60 pe.cor.fa stdout \
        | repair.sh \
            in=stdin.fa \
            out=re-pair/R1.fa \
            out2=re-pair/R2.fa \
            outs=re-pair/Rs.fa \
            threads=[% opt.parallel %] \
            repair overwrite

    # spades seems ignore non-properly paired reads
    spades.py \
        -t [% opt.parallel %] \
        --only-assembler \
        -k 31,41,51,61,71,81 \
        -1 re-pair/R1.fa \
        -2 re-pair/R2.fa \
        -s re-pair/Rs.fa \
        -o .

    anchr contained \
        contigs.fasta \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin k_unitigs.fasta

    find . -type d -not -name "anchor" | parallel --no-run-if-empty -j 1 rm -fr

    END_TIME=\$(date +%s)
    RUNTIME=\$((END_TIME-START_TIME))

    TJQ=\$(jq \".RUNTIME = \"\${RUNTIME}\"\" < environment.json)
    [[ \$? == 0 ]] && echo \"\${TJQ}\" >| environment.json

    SUM_COR=\$( faops n50 -H -N 0 -S pe.cor.fa )

    TJQ=\$(jq \".SUM_COR = \"\${SUM_COR}\"\" < environment.json)
    [[ \$? == 0 ]] && echo \"\${TJQ}\" >| environment.json

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_anchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "4_anchors.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 4_downSampling/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 4_kunitigs/Q{1}L{2}X{3}P{4}'
    if [ -e 4_kunitigs/Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    if [ ! -s 4_kunitigs/Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta does not exist or is empty'
        exit;
    fi

    if [ -d 4_kunitigs/Q{1}L{2}X{3}P{4}/anchor ]; then
        rm -fr 4_kunitigs/Q{1}L{2}X{3}P{4}/anchor
    fi
    mkdir -p 4_kunitigs/Q{1}L{2}X{3}P{4}/anchor
    cd 4_kunitigs/Q{1}L{2}X{3}P{4}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: 0 [% opt.qual2 %] ::: 0 [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( $opt->{tadpole} ) {
        $sh_name = "4_tadpoleAnchors.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 4_downSampling/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 4_tadpole/Q{1}L{2}X{3}P{4}'
    if [ -e 4_tadpole/Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    if [ -d 4_tadpole/Q{1}L{2}X{3}P{4}/anchor ]; then
        rm -fr 4_tadpole/Q{1}L{2}X{3}P{4}/anchor
    fi
    mkdir -p 4_tadpole/Q{1}L{2}X{3}P{4}/anchor
    cd 4_tadpole/Q{1}L{2}X{3}P{4}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: 0 [% opt.qual2 %] ::: 0 [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_6_anchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{mergereads};
    return if $opt->{se};

    $sh_name = "6_anchors.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 6_downSampling/MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 6_kunitigs/MRX{1}P{2}'
    if [ -e 6_kunitigs/MRX{1}P{2}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    if [ -d 6_kunitigs/MRX{1}P{2}/anchor ]; then
        rm -fr 6_kunitigs/MRX{1}P{2}/anchor
    fi
    mkdir -p 6_kunitigs/MRX{1}P{2}/anchor
    cd 6_kunitigs/MRX{1}P{2}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( $opt->{tadpole} ) {
        $sh_name = "6_tadpoleAnchors.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 6_downSampling/MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 6_tadpole/MRX{1}P{2}'
    if [ -e 6_tadpole/MRX{1}P{2}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    if [ -d 6_tadpole/MRX{1}P{2}/anchor ]; then
        rm -fr 6_tadpole/MRX{1}P{2}/anchor
    fi
    mkdir -p 6_tadpole/MRX{1}P{2}/anchor
    cd 6_tadpole/MRX{1}P{2}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

    if ( $opt->{megahit} ) {
        $sh_name = "6_megahitAnchors.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 6_downSampling/MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 6_megahit/MRX{1}P{2}'
    if [ -e 6_megahit/MRX{1}P{2}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    if [ -d 6_megahit/MRX{1}P{2}/anchor ]; then
        rm -fr 6_megahit/MRX{1}P{2}/anchor
    fi
    mkdir -p 6_megahit/MRX{1}P{2}/anchor
    cd 6_megahit/MRX{1}P{2}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        --ratio 0.99 \
        --fill 3 \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

    if ( $opt->{spades} ) {
        $sh_name = "6_spadesAnchors.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 6_downSampling/MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> 6_spades/MRX{1}P{2}'
    if [ -e 6_spades/MRX{1}P{2}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    if [ -d 6_spades/MRX{1}P{2}/anchor ]; then
        rm -fr 6_spades/MRX{1}P{2}/anchor
    fi
    mkdir -p 6_spades/MRX{1}P{2}/anchor
    cd 6_spades/MRX{1}P{2}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        --ratio 0.99 \
        --fill 3 \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..[% opt.splitp %]})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_statAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statAnchors.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_statMRAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statMRAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statMRAnchors.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_mergeAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "7_mergeAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '7_mergeAnchors.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_statMergeAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statMergeAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statMergeAnchors.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_canu {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{cov3};

    $sh_name = "5_canu.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 5_canu.sh

parallel --no-run-if-empty --linebuffer -k -j 1 "
    echo >&2 '==> Group X{1}-{2}'

    if [ ! -e 3_long/L.X{1}.{2}.fasta.gz ]; then
        echo >&2 '  3_long/L.X{1}.{2}.fasta.gz not exists'
        exit;
    fi

    if [ -e 5_canu_X{1}-{2}/*.contigs.fasta ]; then
        echo >&2 '  5_canu_X{1}-{2}/contigs.fasta already presents'
        exit;
    fi

    canu \
        -p [% opt.basename %] \
        -d 5_canu_X{1}-{2} \
        useGrid=false \
        genomeSize=[% opt.genome %] \
        -pacbio-raw 3_long/L.X{1}.{2}.fasta.gz
    " ::: [% opt.cov3 %] ::: [% opt.qual3 %]

# sometimes canu failed
exit;

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_statCanu {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{cov3};

    $sh_name = "9_statCanu.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statCanu.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_anchorLong {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless ( $opt->{cov3} or $opt->{fillanchor} );

    $sh_name = "7_anchorLong.sh";
    print "Create $sh_name\n";

    $tt->process(
        '7_anchorLong.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_anchorFill {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless ( $opt->{cov3} or $opt->{fillanchor} );

    $sh_name = "7_anchorFill.sh";
    print "Create $sh_name\n";

    $tt->process(
        '7_anchorFill.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_spades {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "8_spades.sh";
    print "Create $sh_name\n";

    $tt->process(
        '8_spades.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( !$opt->{se} and $opt->{mergereads} ) {
        $sh_name = "8_spades_MR.sh";
        print "Create $sh_name\n";

        $tt->process(
            '8_spades_MR.tt2',
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_megahit {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "8_megahit.sh";
    print "Create $sh_name\n";

    $tt->process(
        '8_megahit.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( !$opt->{se} and $opt->{mergereads} ) {
        $sh_name = "8_megahit_MR.sh";
        print "Create $sh_name\n";

        $tt->process(
            '8_megahit_MR.tt2',
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_platanus {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "8_platanus.sh";
    print "Create $sh_name\n";

    $tt->process(
        '8_platanus.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_statOtherAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statOtherAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statOtherAnchors.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_trinity {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{trinity};

    #@type Path::Tiny
    my $statbin;
    {    # find util/TrinityStats.pl
        my $bin  = IPC::Cmd::can_run("Trinity");
        my $path = Path::Tiny::path($bin)->realpath;

        if ( $path->parent->child("util")->is_dir ) {
            $statbin = $path->parent()->child("util/TrinityStats.pl");
        }
        else {
            $statbin = $path->parent(2)->child("libexec/util/TrinityStats.pl");
        }
        if ( !$statbin->is_file ) {
            print STDERR YAML::Syck::Dump(
                {   "bin"    => $bin,
                    "path"   => $path,
                    "wanted" => $statbin
                }
            );
            Carp::croak "Can't find TrinityStats.pl\n";
        }
    }

    $sh_name = "8_trinity.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

#----------------------------#
# set parameters
#----------------------------#
USAGE="Usage: $0 DIR_READS"

DIR_READS=${1:-"2_illumina/trim"}

# Convert to abs path
DIR_READS="$(cd "$(dirname "$DIR_READS")"; pwd)/$(basename "$DIR_READS")"

if [ -e 8_trinity/Trinity.fasta ]; then
    log_info "8_trinity/Trinity.fasta presents"
    exit;
fi

#----------------------------#
# trinity
#----------------------------#
log_info "Run trinity"

mkdir -p 8_trinity
cd 8_trinity

mkdir -p re-pair
parallel --no-run-if-empty --linebuffer -k -j 3 "
    if [ ! -e ${DIR_READS}/{}.fq.gz ]; then
        exit;
    fi

    pigz -dcf ${DIR_READS}/{}.fq.gz > re-pair/{}.fq
    " ::: R1 R2

Trinity \
    --seqType fq \
    --left   re-pair/R1.fq \
    --right  re-pair/R2.fq \
    --max_memory [% opt.xmx FILTER upper %] \
    --CPU [% opt.parallel %] \
    --bypass_java_version_check \
    --no_version_check  \
    --min_contig_length [% opt.rnamin %] \
    --output trinity_out_dir \

perl [% statbin %] \
    trinity_out_dir/Trinity.fasta \
    > trinity_out_dir/Trinity.stats

cp trinity_out_dir/Trinity.fasta  .
cp trinity_out_dir/Trinity.stats  .
cp trinity_out_dir/Trinity.timing .

rm -fr trinity_out_dir
rm -fr re-pair

exit;

EOF
    $tt->process(
        \$template,
        {   args    => $args,
            opt     => $opt,
            sh      => $sh_name,
            statbin => $statbin,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    $sh_name = "8_trinity_cor.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

#----------------------------#
# set parameters
#----------------------------#
USAGE="Usage: $0 DIR_READS"

DIR_READS=${1:-"2_illumina/trim"}

# Convert to abs path
DIR_READS="$(cd "$(dirname "$DIR_READS")"; pwd)/$(basename "$DIR_READS")"

if [ -e 8_trinity_cor/Trinity.fasta ]; then
    log_info "8_trinity_cor/Trinity.fasta presents"
    exit;
fi

#----------------------------#
# trinity
#----------------------------#
log_info "Run trinity"

mkdir -p 8_trinity_cor
cd 8_trinity_cor

Trinity \
    --seqType fa \
    --single ${DIR_READS}/pe.cor.fa.gz \
    --run_as_paired \
    --max_memory [% opt.xmx FILTER upper %] \
    --CPU [% opt.parallel %] \
    --bypass_java_version_check \
    --no_version_check  \
    --min_contig_length [% opt.rnamin %] \
    --output trinity_out_dir \

perl [% statbin %] \
    trinity_out_dir/Trinity.fasta \
    > trinity_out_dir/Trinity.stats

cp trinity_out_dir/Trinity.fasta  .
cp trinity_out_dir/Trinity.stats  .
cp trinity_out_dir/Trinity.timing .

rm -fr trinity_out_dir

exit;

EOF
    $tt->process(
        \$template,
        {   args    => $args,
            opt     => $opt,
            sh      => $sh_name,
            statbin => $statbin,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( !$opt->{se} and $opt->{mergereads} ) {
        $sh_name = "8_trinity_MR.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

#----------------------------#
# set parameters
#----------------------------#
USAGE="Usage: $0 DIR_READS"

DIR_READS=${1:-"2_illumina/mergereads"}

# Convert to abs path
DIR_READS="$(cd "$(dirname "$DIR_READS")"; pwd)/$(basename "$DIR_READS")"

if [ -e 8_trinity_MR/Trinity.fasta ]; then
    log_info "8_trinity_MR/Trinity.fasta presents"
    exit;
fi

#----------------------------#
# trinity
#----------------------------#
log_info "Run trinity"

mkdir -p 8_trinity_MR
cd 8_trinity_MR

Trinity \
    --seqType fa \
    --single ${DIR_READS}/pe.cor.fa.gz \
    --run_as_paired \
    --max_memory [% opt.xmx FILTER upper %] \
    --CPU [% opt.parallel %] \
    --bypass_java_version_check \
    --no_version_check  \
    --min_contig_length [% opt.rnamin %] \
    --output trinity_out_dir \

perl [% statbin %] \
    trinity_out_dir/Trinity.fasta \
    > trinity_out_dir/Trinity.stats

cp trinity_out_dir/Trinity.fasta  .
cp trinity_out_dir/Trinity.stats  .
cp trinity_out_dir/Trinity.timing .

rm -fr trinity_out_dir

exit;

EOF
        $tt->process(
            \$template,
            {   args    => $args,
                opt     => $opt,
                sh      => $sh_name,
                statbin => $statbin,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_quast {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_quast.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_quast.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_statFinal {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statFinal.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statFinal.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_cleanup {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "0_cleanup.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

# bax2bam
rm -fr 3_long/bam/*
rm -fr 3_long/fasta/*
rm -fr 3_long/untar/*

# illumina
parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ -e 2_illumina/{}.fq.gz ]; then
        rm 2_illumina/{}.fq.gz;
        touch 2_illumina/{}.fq.gz;
    fi
    " ::: clumpify filteredbytile sample trim filter

# insertSize
rm -f 2_illumina/insertSize/*tadpole.contig.fasta

# quorum
find 2_illumina -type f -name "quorum_mer_db.jf" | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "k_u_hash_0"       | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "*.tmp"            | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "pe.renamed.fastq" | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "se.renamed.fastq" | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "pe.cor.log"       | parallel --no-run-if-empty -j 1 rm

# down sampling
rm -fr 4_downSampling/
find . -type f -path "*4_kunitigs/*" -name "k_unitigs_K*.fasta"  | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_kunitigs/*/anchor*" -name "basecov.txt" | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_kunitigs/*/anchor*" -name "*.sam"       | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_tadpole/*" -name "k_unitigs_K*.fasta"   | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_tadpole/*/anchor*" -name "basecov.txt"  | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_tadpole/*/anchor*" -name "*.sam"        | parallel --no-run-if-empty -j 1 rm

rm -fr 6_downSampling
find . -type f -path "*6_kunitigs/*" -name "k_unitigs_K*.fasta"  | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_kunitigs/*/anchor*" -name "basecov.txt" | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_kunitigs/*/anchor*" -name "*.sam"       | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_tadpole/*" -name "k_unitigs_K*.fasta"   | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_tadpole/*/anchor*" -name "basecov.txt"  | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_tadpole/*/anchor*" -name "*.sam"        | parallel --no-run-if-empty -j 1 rm

# tempdir
find . -type d -name "\?" | xargs rm -fr

# canu
find . -type d -name "correction" -path "*5_canu_*" | parallel --no-run-if-empty -j 1 rm -fr
find . -type d -name "trimming"   -path "*5_canu_*" | parallel --no-run-if-empty -j 1 rm -fr
find . -type d -name "unitigging" -path "*5_canu_*" | parallel --no-run-if-empty -j 1 rm -fr

# anchorLong and anchorFill
find . -type d -name "group"         -path "*7_anchor*" | parallel --no-run-if-empty -j 1 rm -fr
find . -type f -name "long.fasta"    -path "*7_anchor*" | parallel --no-run-if-empty -j 1 rm
find . -type f -name ".anchorLong.*" -path "*7_anchor*" | parallel --no-run-if-empty -j 1 rm

# spades
find . -type d -path "*8_spades/*" -not -name "anchor" | parallel --no-run-if-empty -j 1 rm -fr

# platanus
find . -type f -path "*8_platanus/*" -name "[ps]e.fa" | parallel --no-run-if-empty -j 1 rm

# quast
find . -type d -name "nucmer_output" | parallel --no-run-if-empty -j 1 rm -fr
find . -type f -path "*contigs_reports/*" -name "*.stdout*" -or -name "*.stderr*" | parallel --no-run-if-empty -j 1 rm

# LSF outputs and dumps
find . -type f -name "output.*" | parallel --no-run-if-empty -j 1 rm
find . -type f -name "core.*"   | parallel --no-run-if-empty -j 1 rm

# cat all .md
if [ -e statInsertSize.md ]; then
    echo;
    cat statInsertSize.md;
    echo;
fi
if [ -e statSgaStats.md ]; then
    echo;
    cat statSgaStats.md;
    echo;
fi
if [ -e statReads.md ]; then
    echo;
    cat statReads.md;
    echo;
fi
if [ -e statTrimReads.md ]; then
    echo;
    cat statTrimReads.md;
    echo;
fi
if [ -e statMergeReads.md ]; then
    echo;
    cat statMergeReads.md;
    echo;
fi
if [ -e statQuorum.md ]; then
    echo;
    cat statQuorum.md;
    echo;
fi
if [ -e statAnchors.md ]; then
    echo;
    cat statAnchors.md;
    echo;
fi
if [ -e statKunitigsAnchors.md ]; then
    echo;
    cat statKunitigsAnchors.md;
    echo;
fi
if [ -e statTadpoleAnchors.md ]; then
    echo;
    cat statTadpoleAnchors.md;
    echo;
fi
if [ -e statMRKunitigsAnchors.md ]; then
    echo;
    cat statMRKunitigsAnchors.md;
    echo;
fi
if [ -e statMRTadpoleAnchors.md ]; then
    echo;
    cat statMRTadpoleAnchors.md;
    echo;
fi
if [ -e statMergeAnchors.md ]; then
    echo;
    cat statMergeAnchors.md;
    echo;
fi
if [ -e statOtherAnchors.md ]; then
    echo;
    cat statOtherAnchors.md;
    echo;
fi
if [ -e statCanu.md ]; then
    echo;
    cat statCanu.md;
    echo;
fi
if [ -e statFinal.md ]; then
    echo;
    cat statFinal.md;
    echo;
fi

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_realClean {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "0_realClean.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

# illumina
rm -f 2_illumina/Q*

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ -e 2_illumina/{1}.{2}.fq.gz ]; then
        rm 2_illumina/{1}.{2}.fq.gz;
    fi
    " ::: R1 R2 Rs ::: uniq shuffle sample bbduk clean

rm -fr 2_illumina/trim/
rm -fr 2_illumina/mergereads/

# Long
rm -fr 3_long/bam
rm -fr 3_long/fasta
rm -fr 3_long/untar

rm 3_long/L.X*.fasta
rm 3_long/L.X*.fasta.gz

# down sampling
rm -fr 4_downSampling
rm -fr 4_kunitigs*
rm -fr 4_tadpole*

rm -fr 6_downSampling
rm -fr 6_kunitigs*
rm -fr 6_tadpole*

# canu
rm -fr 5_canu*

# mergeAnchors, anchorLong and anchorFill
rm -fr 7_merge*
rm -fr 7_anchor*
rm -fr 7_fillAnchor

# spades, platanus, and megahit
rm -fr 8_spades*
rm -fr 8_platanus*
rm -fr 8_megahit*

# quast
rm -fr 9_quast*

# tempdir
find . -type d -name "\?" | parallel --no-run-if-empty -j 1 rm -fr

# LSF outputs and dumps
find . -type f -name "output.*" | parallel --no-run-if-empty -j 1 rm
find . -type f -name "core.*"   | parallel --no-run-if-empty -j 1 rm

# .md
rm *.md

# bash
rm *.sh

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_master {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "0_master.sh";
    print "Create $sh_name\n";

    $tt->process(
        '0_master.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_bsub {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "0_bsub.sh";
    print "Create $sh_name\n";

    $tt->process(
        '0_bsub.tt2',
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

1;
